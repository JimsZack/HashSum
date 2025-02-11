#!/bin/bash

# 设置构建目录
BUILD_DIR="build"
mkdir -p $BUILD_DIR

# 设置版本信息
VERSION="1.0.0"

# 设置目标平台
PLATFORMS="windows linux darwin"
ARCHS="amd64 386 arm64"

# 设置程序名称
PROG_NAME="HashSum"

echo "Building $PROG_NAME version $VERSION..."

# 遍历平台和架构
for GOOS in $PLATFORMS; do
    for GOARCH in $ARCHS; do
        # 跳过不支持的组合
        if [ "$GOOS-$GOARCH" == "darwin-386" ]; then
            continue
        fi

        # 设置输出文件名
        OUT_NAME=$PROG_NAME
        if [ "$GOOS" == "windows" ]; then
            OUT_NAME="${OUT_NAME}.exe"
        fi

        # 创建目标目录
        TARGET_DIR="${BUILD_DIR}/${GOOS}-${GOARCH}-v${VERSION}"
        mkdir -p $TARGET_DIR

        echo "Building for $GOOS/$GOARCH..."
        GOOS=$GOOS GOARCH=$GOARCH go build -o "${TARGET_DIR}/${OUT_NAME}" .

        # 复制README或其他文件（如果有的话）
        if [ -f "README.md" ]; then
            cp README.md $TARGET_DIR/
        fi
    done
done

echo "Build complete!"

# 在Unix系统上设置可执行权限
chmod +x build/*.sh 2>/dev/null || true 