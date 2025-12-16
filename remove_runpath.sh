#!/bin/bash
set -e  # 出错退出

# OpenCV 安装目录（你的路径）
OPENCV_INSTALL_DIR="/home/dongshucai/Downloads/copy_opencv_libs/opencv_libs"

echo "处理 .so 文件 RUNPATH..."

# 正确循环写法
for lib in "$OPENCV_INSTALL_DIR"/lib/*.so*; do
    if [ -f "$lib" ]; then
        echo "处理: $lib"

        # 方法1：清除 RUNPATH（推荐）
        # patchelf --remove-rpath "$lib"

        # 方法2：如果想强制设置为纯相对路径，取消下面注释
        patchelf --set-rpath '$ORIGIN' "$lib"
    fi
done

echo "所有 .so 文件 RUNPATH 处理完成！"