@echo off
setlocal enabledelayedexpansion

:: 设置构建目录
set BUILD_DIR=build
if not exist %BUILD_DIR% mkdir %BUILD_DIR%

:: 设置版本信息
set VERSION=1.0.0

:: 设置目标平台
set PLATFORMS=windows linux darwin
set ARCHS=amd64 386 arm64

:: 设置程序名称
set PROG_NAME=HashSum

echo Building %PROG_NAME% version %VERSION%...

:: 遍历平台和架构
for %%p in (%PLATFORMS%) do (
    for %%a in (%ARCHS%) do (
        :: 跳过不支持的组合
        if not "%%p-%%a"=="darwin-386" (
            set GOOS=%%p
            set GOARCH=%%a
            
            :: 设置输出文件名
            set OUT_NAME=%PROG_NAME%
            if "%%p"=="windows" (
                set OUT_NAME=!OUT_NAME!.exe
            )
            
            echo Building for %%p/%%a...
            go build -o %BUILD_DIR%/%%p-%%a-v%VERSION%/!OUT_NAME! .
            
            :: 复制README或其他文件（如果有的话）
            if exist README.md (
                copy README.md %BUILD_DIR%/%%p-%%a-v%VERSION%/
            )
        )
    )
)

echo Build complete! 