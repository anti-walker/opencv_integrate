#!/bin/bash
set -e  # 出错立即退出

# ================ 使用说明 ================
if [ $# -ne 1 ]; then
    echo "用法: $0 <OPENCV_SO_DIR>"
    echo "示例: $0 /home/user/Downloads/copy_opencv_libs/opencv_x86"
    echo "      $0 /home/user/Downloads/copy_opencv_libs/opencv_arm64"
    exit 1
fi

# ================ 参数 ================
OPENCV_SO_DIR="$1"  # 从命令行参数获取

# 检查目录是否存在
if [ ! -d "$OPENCV_SO_DIR" ]; then
    echo "错误: 目录不存在 -> $OPENCV_SO_DIR"
    exit 1
fi

LIB_DIR="$OPENCV_SO_DIR/lib"

if [ ! -d "$LIB_DIR" ]; then
    echo "错误: lib 目录不存在 -> $LIB_DIR"
    exit 1
fi

echo "开始处理 .so 文件 RUNPATH..."
echo "目标目录: $LIB_DIR"
echo

# 循环处理所有 .so 文件（包括 .so、.so.410、.so.4.10.0 等）
for lib in "$LIB_DIR"/*.so*; do
    # 检查是否为普通文件（避免匹配不存在时产生的字面量 "*.so*"）
    if [ -f "$lib" ]; then
        echo "处理: $lib"

        # 方法1：清除 RUNPATH（推荐，依赖最终可执行文件的 rpath）
        # patchelf --remove-rpath "$lib"

        # 方法2：强制设置为纯相对路径（当前目录）
        patchelf --set-rpath '$ORIGIN' "$lib"

        echo "  → RUNPATH 已设置为 \$ORIGIN"
    fi
done

echo
echo "所有 .so 文件 RUNPATH 处理完成！"