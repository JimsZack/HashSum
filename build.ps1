# 设置构建目录
$BUILD_DIR = "build"
if (-not (Test-Path $BUILD_DIR)) {
    New-Item -ItemType Directory -Path $BUILD_DIR
}

# 设置版本信息
$VERSION = "1.0.0"

# 设置目标平台
$PLATFORMS = @("windows", "linux", "darwin")
$ARCHS = @("amd64", "386", "arm64")

# 设置程序名称
$PROG_NAME = "HashSum"

Write-Host "Building $PROG_NAME version $VERSION..."

# 遍历平台和架构
foreach ($GOOS in $PLATFORMS) {
    foreach ($GOARCH in $ARCHS) {
        # 跳过不支持的组合
        if ("$GOOS-$GOARCH" -eq "darwin-386") {
            continue
        }

        # 设置输出文件名
        $OUT_NAME = $PROG_NAME
        if ($GOOS -eq "windows") {
            $OUT_NAME = "${OUT_NAME}.exe"
        }

        # 设置环境变量
        $env:GOOS = $GOOS
        $env:GOARCH = $GOARCH

        $TARGET_DIR = "$BUILD_DIR/${GOOS}-${GOARCH}-v${VERSION}"
        if (-not (Test-Path $TARGET_DIR)) {
            New-Item -ItemType Directory -Path $TARGET_DIR
        }

        Write-Host "Building for $GOOS/$GOARCH..."
        go build -o "$TARGET_DIR/$OUT_NAME" .

        # 复制README或其他文件（如果有的话）
        if (Test-Path "README.md") {
            Copy-Item "README.md" -Destination $TARGET_DIR
        }
    }
}

Write-Host "Build complete!" 