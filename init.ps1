Write-Host "Initializing Go project..."

# 初始化 Go 模块
if (-not (Test-Path go.mod)) {
    Write-Host "Creating go module..."
    go mod init HashSum
}

# 下载依赖
Write-Host "Downloading dependencies..."
go mod tidy

# 验证依赖
Write-Host "Verifying dependencies..."
go mod verify

Write-Host "Initialization complete!" 