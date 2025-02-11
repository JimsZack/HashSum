@echo off
echo Initializing Go project...

:: 初始化 Go 模块
if not exist go.mod (
    echo Creating go module...
    go mod init HashSum
)

:: 下载依赖
echo Downloading dependencies...
go mod tidy

:: 验证依赖
echo Verifying dependencies...
go mod verify

echo Initialization complete! 