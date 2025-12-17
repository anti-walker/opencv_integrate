#!/bin/bash
set -e  # 出错立即退出

# ================ 使用说明 ================
if [ $# -ne 3 ]; then
    echo "用法: $0 <OPENCV_SO_DIR> <DEB_ROOT_DIR> <PACKAGE_NAME>"
    echo "示例:"
    echo "  $0 /home/user/copy_opencv_libs/opencv_x86 ~/deb_build opencv_x86_badp"
    echo "  $0 /home/user/copy_opencv_libs/opencv_arm64 ~/deb_build opencv_arm64_badp"
    exit 1
fi

# ================ 参数 ================
OPENCV_SO_DIR="$1"      # OpenCV 安装产物根目录
DEB_ROOT_DIR="$2"       # DEB 临时构建根目录
PACKAGE_NAME="$3"       # 包名，例如 opencv_x86_badp

VERSION="4.10.0-1"
PACKAGE_DIR="${DEB_ROOT_DIR}/${PACKAGE_NAME}"
CONTROL_DIR="${PACKAGE_DIR}/DEBIAN"

# ================ 参数校验 ================
if [ ! -d "$OPENCV_SO_DIR" ]; then
    echo "错误: OPENCV_SO_DIR 不存在 -> $OPENCV_SO_DIR"
    exit 1
fi

# ================ 开始打包 ================
echo "开始打包 OpenCV DEB..."
echo "来源目录: $OPENCV_SO_DIR"
echo "构建目录: $DEB_ROOT_DIR"
echo "包名: $PACKAGE_NAME"
echo

# 1. 清空并创建目录
rm -rf "$DEB_ROOT_DIR"
mkdir -p "$PACKAGE_DIR/usr/local"
mkdir -p "$CONTROL_DIR"

# 2. 复制 OpenCV 所有产物到 /usr/local/
echo "复制 OpenCV 安装文件..."
cp -r "$OPENCV_SO_DIR"/* "$PACKAGE_DIR/usr/local/"

# 3. 创建 control 文件
echo "创建 control 文件..."
cat > "$CONTROL_DIR/control" << EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: libs
Priority: optional
Architecture: all
Maintainer: Your Name <you@company.com>
Depends: libc6, libstdc++6, libgtk-3-0 (>= 3.0.0), libavcodec58, libavformat58, libswscale5
Description: OpenCV 4.10.0 built with Bazel
 OpenCV libraries compiled from source using Bazel and rules_foreign_cc.
 Includes all main modules (except ts).
EOF

# 4. 创建 postinst 脚本（安装后更新 ldconfig）
echo "创建 postinst 脚本..."
cat > "$CONTROL_DIR/postinst" << 'EOF'
#!/bin/sh
ldconfig
EOF

# 5. 设置文件权限
echo "设置文件权限..."
find "$PACKAGE_DIR" -type d -exec chmod 755 {} \;
find "$PACKAGE_DIR" -type f -exec chmod 644 {} \;
chmod 755 "$PACKAGE_DIR/usr/local/lib"/*.so*  # .so 文件必须可执行

# 最后确保 postinst 可执行（防止被上面的 644 覆盖）
chmod 755 "$CONTROL_DIR/postinst"

# 6. 构建 DEB 包
echo "构建 DEB 包..."
cd "$DEB_ROOT_DIR"
dpkg-deb --build "$PACKAGE_NAME"

# 7. 输出结果
DEB_FILE="${DEB_ROOT_DIR}/${PACKAGE_NAME}.deb"
echo
echo "DEB 包生成完成：$DEB_FILE"
ls -lh "$DEB_FILE"
echo "SHA256 checksum："
sha256sum "$DEB_FILE"