#!/bin/bash

echo "Initializing Go project..."

# 初始化 Go 模块
if [ ! -f go.mod ]; then
    echo "Creating go module..."
    go mod init HashSum
fi

# 下载依赖
echo "Downloading dependencies..."
go mod tidy

# 验证依赖
echo "Verifying dependencies..."
go mod verify

echo "Initialization complete!"

# 设置脚本执行权限
chmod +x *.sh 