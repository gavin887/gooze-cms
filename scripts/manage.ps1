<#
.SYNOPSIS
    Gooze-CMS 工程化管理脚本 (Windows PowerShell 版本)
.DESCRIPTION
    提供 Gooze-CMS 项目的启动、停止、重启、状态检查、构建打包等功能
.NOTES
    兼容 Windows PowerShell 5.1+
#>

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ApiDir = Join-Path $ProjectRoot "gooze-vben-api"
$AdminDir = Join-Path $ProjectRoot "gooze-vben-admin"
$BuildDir = Join-Path $ProjectRoot "build"
$PidDir = Join-Path $BuildDir "pids"
$LogsDir = Join-Path $BuildDir "logs"

$ApiPidFile = Join-Path $PidDir "api.pid"
$AdminPidFile = Join-Path $PidDir "admin.pid"
$ApiLogFile = Join-Path $LogsDir "api.log"
$AdminLogFile = Join-Path $LogsDir "admin.log"

$ApiPort = 8000
$AdminPort = 5173

function Ensure-Dirs {
    if (-not (Test-Path $PidDir)) { New-Item -ItemType Directory -Path $PidDir -Force | Out-Null }
    if (-not (Test-Path $LogsDir)) { New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null }
}

function Write-Color {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

function Write-Banner {
    Write-Color "==========================================" "Cyan"
    Write-Color "       Gooze-CMS 管理控制台 (Windows)     " "Cyan"
    Write-Color "==========================================" "Cyan"
    Write-Host ""
}

function Test-ProcessRunning {
    param([string]$PidFile)
    if (-not (Test-Path $PidFile)) { return $false }
    $procId = Get-Content $PidFile -ErrorAction SilentlyContinue
    if (-not $procId) { return $false }
    try {
        $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
        if ($proc -and -not $proc.HasExited) { return $true }
    } catch {}
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    return $false
}

function Get-PidSafe {
    param([string]$PidFile)
    if (Test-Path $PidFile) {
        $content = Get-Content $PidFile -ErrorAction SilentlyContinue
        if ($content) { return [int]$content }
    }
    return $null
}

function Get-ServiceStatus {
    param(
        [string]$Name,
        [string]$PidFile,
        [string]$Port
    )
    $running = Test-ProcessRunning $PidFile
    $procId = Get-PidSafe $PidFile
    $portInUse = $false
    try {
        $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if ($connections) { $portInUse = $true }
    } catch {}
    return [PSCustomObject]@{
        Name      = $Name
        Running   = $running
        Pid       = $procId
        Port      = $Port
        PortInUse = $portInUse
    }
}

function Invoke-Status {
    Write-Banner
    Write-Color "[服务状态检查]" "Yellow"
    Write-Host ""

    $apiStatus = Get-ServiceStatus -Name "后端 API 服务" -PidFile $ApiPidFile -Port $ApiPort
    $adminStatus = Get-ServiceStatus -Name "前端 Admin 服务" -PidFile $AdminPidFile -Port $AdminPort

    $services = @($apiStatus, $adminStatus)
    foreach ($svc in $services) {
        $statusText = if ($svc.Running) { "运行中" } else { "已停止" }
        $statusColor = if ($svc.Running) { "Green" } else { "Red" }
        $portText = if ($svc.PortInUse) { "占用" } else { "空闲" }
        $portColor = if ($svc.PortInUse) { "Yellow" } else { "Gray" }
        $pidText = if ($svc.Pid) { "PID: $($svc.Pid)" } else { "PID: -" }

        Write-Color "  $($svc.Name)" "White"
        Write-Host "    状态: " -NoNewline
        Write-Color $statusText $statusColor -NoNewline
        Write-Host "  |  端口($($svc.Port)): " -NoNewline
        Write-Color $portText $portColor -NoNewline
        Write-Host "  |  $pidText"
        Write-Host ""
    }

    $apiUrl = "http://localhost:$ApiPort"
    $adminUrl = "http://localhost:$AdminPort"
    Write-Color "[访问地址]" "Yellow"
    Write-Host "  前端管理台: " -NoNewline
    Write-Color $adminUrl "Cyan"
    Write-Host "  后端API:    " -NoNewline
    Write-Color $apiUrl "Cyan"
    Write-Host ""
}

function Start-Api {
    Ensure-Dirs
    if (Test-ProcessRunning $ApiPidFile) {
        Write-Color "[警告] 后端 API 服务已在运行中 (PID: $(Get-PidSafe $ApiPidFile))" "Yellow"
        return
    }

    Write-Color "[启动] 后端 API 服务..." "Green"
    Set-Location $ApiDir

    $env:GO_ENV = "development"
    $startArgs = @(
        "-NoProfile",
        "-NonInteractive",
        "-Command",
        "Set-Location '$ApiDir'; `$env:GO_ENV='development'; go run ./cmd/admin/main.go --config='./configs/admin.yaml' --env='.env.admin' --show=false 2>&1 | Tee-Object -FilePath '$ApiLogFile'"
    )

    $proc = Start-Process -FilePath "powershell.exe" -ArgumentList $startArgs `
        -WindowStyle Hidden `
        -RedirectStandardOutput $ApiLogFile `
        -RedirectStandardError $ApiLogFile `
        -PassThru

    $proc.Id | Out-File -FilePath $ApiPidFile -Encoding utf8
    Start-Sleep -Seconds 3
    if (Test-ProcessRunning $ApiPidFile) {
        Write-Color "[成功] 后端 API 服务已启动 (PID: $($proc.Id), 端口: $ApiPort)" "Green"
    } else {
        Write-Color "[失败] 后端 API 服务启动失败，请查看日志: $ApiLogFile" "Red"
    }
}

function Start-Admin {
    Ensure-Dirs
    if (Test-ProcessRunning $AdminPidFile) {
        Write-Color "[警告] 前端 Admin 服务已在运行中 (PID: $(Get-PidSafe $AdminPidFile))" "Yellow"
        return
    }

    Write-Color "[启动] 前端 Admin 服务..." "Green"
    Set-Location $AdminDir

    $logWriter = [System.IO.StreamWriter]::new($AdminLogFile, $true)
    $proc = Start-Process -FilePath "pnpm.cmd" -ArgumentList "dev" `
        -WorkingDirectory $AdminDir `
        -WindowStyle Hidden `
        -RedirectStandardOutput $AdminLogFile `
        -RedirectStandardError $AdminLogFile `
        -PassThru

    $proc.Id | Out-File -FilePath $AdminPidFile -Encoding utf8
    Start-Sleep -Seconds 5
    if (Test-ProcessRunning $AdminPidFile) {
        Write-Color "[成功] 前端 Admin 服务已启动 (PID: $($proc.Id), 端口: $AdminPort)" "Green"
    } else {
        Write-Color "[失败] 前端 Admin 服务启动失败，请查看日志: $AdminLogFile" "Red"
    }
}

function Invoke-Start {
    param(
        [ValidateSet("api", "admin", "all")]
        [string]$Service = "all"
    )
    Write-Banner
    switch ($Service) {
        "api"   { Start-Api }
        "admin" { Start-Admin }
        "all"   { Start-Api; Start-Admin }
    }
    Write-Host ""
}

function Stop-Api {
    if (-not (Test-ProcessRunning $ApiPidFile)) {
        Write-Color "[提示] 后端 API 服务未运行" "Gray"
        return
    }
    $procId = Get-PidSafe $ApiPidFile
    Write-Color "[停止] 后端 API 服务 (PID: $procId)..." "Yellow"
    try {
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
        if ($proc -and -not $proc.HasExited) {
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        }
    } catch {}
    Remove-Item $ApiPidFile -Force -ErrorAction SilentlyContinue
    if (-not (Test-ProcessRunning $ApiPidFile)) {
        Write-Color "[完成] 后端 API 服务已停止" "Green"
    }
}

function Stop-Admin {
    if (-not (Test-ProcessRunning $AdminPidFile)) {
        Write-Color "[提示] 前端 Admin 服务未运行" "Gray"
        return
    }
    $procId = Get-PidSafe $AdminPidFile
    Write-Color "[停止] 前端 Admin 服务 (PID: $procId)..." "Yellow"
    try {
        $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
        if ($proc) {
            $children = Get-WmiObject Win32_Process -Filter "ParentProcessId=$procId" -ErrorAction SilentlyContinue
            foreach ($child in $children) {
                Stop-Process -Id $child.ProcessId -Force -ErrorAction SilentlyContinue
            }
        }
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    } catch {}
    Remove-Item $AdminPidFile -Force -ErrorAction SilentlyContinue
    if (-not (Test-ProcessRunning $AdminPidFile)) {
        Write-Color "[完成] 前端 Admin 服务已停止" "Green"
    }
}

function Invoke-Stop {
    param(
        [ValidateSet("api", "admin", "all")]
        [string]$Service = "all"
    )
    Write-Banner
    switch ($Service) {
        "api"   { Stop-Api }
        "admin" { Stop-Admin }
        "all"   { Stop-Admin; Stop-Api }
    }
    Write-Host ""
}

function Invoke-Restart {
    param(
        [ValidateSet("api", "admin", "all")]
        [string]$Service = "all"
    )
    Write-Banner
    Write-Color "[重启] $Service 服务..." "Yellow"
    Write-Host ""
    Invoke-Stop -Service $Service
    Start-Sleep -Seconds 2
    Invoke-Start -Service $Service
}

function Invoke-Reload {
    param(
        [ValidateSet("api", "admin", "all")]
        [string]$Service = "all"
    )
    Write-Banner
    Write-Color "[重载] $Service 服务 (平滑重启)..." "Yellow"
    Write-Host ""
    Invoke-Restart -Service $Service
}

function Invoke-Build {
    param(
        [ValidateSet("api", "admin", "all")]
        [string]$Service = "all",
        [string]$Version = "latest"
    )
    Write-Banner
    Ensure-Dirs
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $ReleaseDir = Join-Path $BuildDir "release-$Version-$Timestamp"
    New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null

    Write-Color "[构建] 目标目录: $ReleaseDir" "Yellow"
    Write-Host ""

    if ($Service -in @("api", "all")) {
        Write-Color "[构建] 后端 API 服务 (Go)..." "Yellow"
        Set-Location $ApiDir
        $ApiBuildDir = Join-Path $ReleaseDir "api"
        New-Item -ItemType Directory -Path $ApiBuildDir -Force | Out-Null

        $binName = if ($IsWindows -or $ENV:OS -eq "Windows_NT") { "gooze-admin-api.exe" } else { "gooze-admin-api" }
        $binPath = Join-Path $ApiBuildDir $binName

        $env:CGO_ENABLED = "0"
        $env:GOOS = "windows"
        $env:GOARCH = "amd64"

        & go build -ldflags "-s -w -X main.Version=$Version -X main.BuildTime=$Timestamp" -o $binPath ./cmd/admin/main.go
        if ($LASTEXITCODE -eq 0) {
            Copy-Item -Path (Join-Path $ApiDir "configs") -Destination $ApiBuildDir -Recurse -Force
            Copy-Item -Path (Join-Path $ApiDir ".env.admin") -Destination $ApiBuildDir -Force
            $fileSize = (Get-Item $binPath).Length / 1MB
            Write-Color "[成功] 后端构建完成: $binPath ($([math]::Round($fileSize, 2)) MB)" "Green"
        } else {
            Write-Color "[失败] 后端构建失败" "Red"
        }
        Write-Host ""
    }

    if ($Service -in @("admin", "all")) {
        Write-Color "[构建] 前端 Admin 服务 (Vite)..." "Yellow"
        Set-Location $AdminDir
        $AdminBuildDir = Join-Path $ReleaseDir "admin"
        New-Item -ItemType Directory -Path $AdminBuildDir -Force | Out-Null

        if (-not (Test-Path (Join-Path $AdminDir "node_modules"))) {
            Write-Color "[提示] 检测到未安装依赖，正在安装..." "Gray"
            & pnpm install
        }

        & pnpm build
        if ($LASTEXITCODE -eq 0) {
            $distDir = Join-Path $AdminDir "apps\admin\dist"
            if (Test-Path $distDir) {
                Copy-Item -Path (Join-Path $distDir "*") -Destination $AdminBuildDir -Recurse -Force
                $totalSize = (Get-ChildItem $AdminBuildDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
                Write-Color "[成功] 前端构建完成: $AdminBuildDir ($([math]::Round($totalSize, 2)) MB)" "Green"
            } else {
                Write-Color "[警告] 前端 dist 目录未找到" "Yellow"
            }
        } else {
            Write-Color "[失败] 前端构建失败" "Red"
        }
        Write-Host ""
    }

    Write-Color "[完成] 构建产物目录: $ReleaseDir" "Cyan"
    Write-Host ""
}

function Invoke-Logs {
    param(
        [ValidateSet("api", "admin")]
        [string]$Service = "api"
    )
    $logFile = if ($Service -eq "api") { $ApiLogFile } else { $AdminLogFile }
    if (-not (Test-Path $logFile)) {
        Write-Color "[提示] 日志文件不存在: $logFile" "Gray"
        return
    }
    Write-Banner
    Write-Color "[日志] $Service - $logFile" "Yellow"
    Write-Host ""
    Get-Content $logFile -Tail 100 -Wait
}

function Invoke-Clean {
    Write-Banner
    Write-Color "[清理] 清理构建产物和临时文件..." "Yellow"
    Write-Host ""

    if (Test-Path $PidDir) {
        Get-ChildItem $PidDir -Filter "*.pid" | ForEach-Object {
            $procId = Get-Content $_.FullName -ErrorAction SilentlyContinue
            if ($procId) {
                try { Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue } catch {}
            }
        }
        Remove-Item $PidDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Color "  - 已清理 PID 目录" "Gray"
    }

    $apiDist = Join-Path $ApiDir "bin"
    if (Test-Path $apiDist) { Remove-Item $apiDist -Recurse -Force -ErrorAction SilentlyContinue; Write-Color "  - 已清理后端 bin 目录" "Gray" }
    $adminDist = Join-Path $AdminDir "apps\admin\dist"
    if (Test-Path $adminDist) { Remove-Item $adminDist -Recurse -Force -ErrorAction SilentlyContinue; Write-Color "  - 已清理前端 dist 目录" "Gray" }

    if (Test-Path $BuildDir) {
        Get-ChildItem $BuildDir -Directory | Where-Object { $_.Name -like "release-*" } | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Color "  - 已清理: $($_.Name)" "Gray"
        }
    }

    Write-Host ""
    Write-Color "[完成] 清理完成" "Green"
    Write-Host ""
}

function Show-Help {
    Write-Banner
    Write-Color "用法:" "Yellow"
    Write-Host "  .\manage.ps1 <命令> [参数]"
    Write-Host ""
    Write-Color "可用命令:" "Yellow"
    Write-Host "  status              查看所有服务运行状态"
    Write-Host "  start [服务]        启动服务 (api|admin|all, 默认: all)"
    Write-Host "  stop  [服务]        停止服务 (api|admin|all, 默认: all)"
    Write-Host "  restart [服务]      重启服务 (api|admin|all, 默认: all)"
    Write-Host "  reload [服务]       重载服务 (api|admin|all, 默认: all)"
    Write-Host "  build [服务] [版本] 构建打包 (api|admin|all, 默认: all)"
    Write-Host "  logs <服务>         实时查看服务日志 (api|admin)"
    Write-Host "  clean               清理构建产物和临时文件"
    Write-Host "  help                显示此帮助信息"
    Write-Host ""
    Write-Color "示例:" "Yellow"
    Write-Host "  .\manage.ps1 status              # 查看状态"
    Write-Host "  .\manage.ps1 start all           # 启动全部服务"
    Write-Host "  .\manage.ps1 restart api         # 重启后端"
    Write-Host "  .\manage.ps1 build all v1.0.0    # 构建全部并指定版本"
    Write-Host "  .\manage.ps1 logs admin          # 查看前端日志"
    Write-Host ""
}

if ($args.Count -eq 0) {
    Show-Help
    exit 0
}

$Command = $args[0].ToLower()

switch ($Command) {
    "status"  { Invoke-Status }
    "start"   { $svc = if ($args[1]) { $args[1].ToLower() } else { "all" }; Invoke-Start -Service $svc }
    "stop"    { $svc = if ($args[1]) { $args[1].ToLower() } else { "all" }; Invoke-Stop -Service $svc }
    "restart" { $svc = if ($args[1]) { $args[1].ToLower() } else { "all" }; Invoke-Restart -Service $svc }
    "reload"  { $svc = if ($args[1]) { $args[1].ToLower() } else { "all" }; Invoke-Reload -Service $svc }
    "build"   {
        $svc = if ($args[1]) { $args[1].ToLower() } else { "all" }
        $ver = if ($args[2]) { $args[2] } else { "latest" }
        Invoke-Build -Service $svc -Version $ver
    }
    "logs"    { $svc = if ($args[1]) { $args[1].ToLower() } else { "api" }; Invoke-Logs -Service $svc }
    "clean"   { Invoke-Clean }
    "help"    { Show-Help }
    "--help"  { Show-Help }
    "-h"      { Show-Help }
    default   {
        Write-Color "[错误] 未知命令: $Command" "Red"
        Write-Host ""
        Show-Help
        exit 1
    }
}

Set-Location $ProjectRoot

