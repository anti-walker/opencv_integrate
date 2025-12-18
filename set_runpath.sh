#!/bin/bash
set -e  # exit on error

# ================ User Manual ================
if [ $# -ne 1 ]; then
    echo "use: $0 <OPENCV_SO_DIR>"
    echo "ex: $0 /home/user/Downloads/copy_opencv_libs/opencv_x86"
    echo "      $0 /home/user/Downloads/copy_opencv_libs/opencv_arm64"
    exit 1
fi

# ================ Params ================
OPENCV_SO_DIR="$1"  # parent directory of opencv*.so files' parent directory

# check if directory exists
if [ ! -d "$OPENCV_SO_DIR" ]; then
    echo "error: dir not exists -> $OPENCV_SO_DIR"
    exit 1
fi

LIB_DIR="$OPENCV_SO_DIR/lib"

if [ ! -d "$LIB_DIR" ]; then
    echo "error: lib directory not exists -> $LIB_DIR"
    exit 1
fi

echo "begin to set .so file RUNPATH..."
echo "target dir: $LIB_DIR"
echo

# ================ Main Logic ================
for lib in "$LIB_DIR"/*.so*; do
    if [ -f "$lib" ]; then
        echo "处理: $lib"

        # method 1：clear RUNPATH
        # patchelf --remove-rpath "$lib"

        # method 2：set RUNPATH to $ORIGIN
        patchelf --set-rpath '$ORIGIN' "$lib"

        echo "  → RUNPATH setted to \$ORIGIN"
    fi
done

echo
echo "all .so files RUNPATH processing completed!"