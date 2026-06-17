#setup-go-env.ps1
$env:GOOS="windows"
$env:GOARCH="amd64"
$env:CGO_ENABLED=1
$env:CC="G:\environments\msys64\mingw64\bin\gcc.exe"
$env:CXX="G:\environments\msys64\mingw64\bin\gcc.exe"
