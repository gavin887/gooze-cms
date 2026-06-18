$TestName = $args[0]

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Gooze CMS Backend API Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "$PSScriptRoot\.."

if ($TestName) {
    Write-Host "Running test: $TestName" -ForegroundColor Yellow
    go test -v ./test -run $TestName
} else {
    Write-Host "Running all tests..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "--- Category Tests ---" -ForegroundColor Green
    go test -v ./test -run "TestCategory"

    Write-Host ""
    Write-Host "--- Tag Tests ---" -ForegroundColor Green
    go test -v ./test -run "TestTag"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test execution completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
