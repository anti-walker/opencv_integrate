#!/bin/bash
set -e

# ============ 配置变量 ============
VERSION="4.10.0-1"
PACKAGE_NAME="opencv-badp"
DEB_ROOT_DIR=~/Downloads/opencv_deb_badp
PACKAGE_DIR="${DEB_ROOT_DIR}/${PACKAGE_NAME}"
CONTROL_DIR="${PACKAGE_DIR}/DEBIAN"   # 确保这里是 PACKAGE_DIR/DEBIAN

OPENCV_INSTALL_DIR="/home/dongshucai/Downloads/copy_opencv_libs/opencv_libs"

# ============ 开始打包 ============
echo "开始打包 OpenCV DEB..."

rm -rf "$DEB_ROOT_DIR"
mkdir -p "$PACKAGE_DIR/usr/local"
mkdir -p "$CONTROL_DIR"

echo "复制 OpenCV 安装文件..."
cp -r "$OPENCV_INSTALL_DIR"/* "$PACKAGE_DIR/usr/local/"

echo "创建 control 文件..."
cat > "$CONTROL_DIR/control" << EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: libs
Priority: optional
Architecture: amd64
Maintainer: Your Name <you@company.com>
Depends: libc6, libstdc++6, libgtk-3-0 (>= 3.0.0), libavcodec58, libavformat58, libswscale5
Description: OpenCV 4.10.0 built with Bazel
 OpenCV libraries compiled from source using Bazel and rules_foreign_cc.
 Includes all main modules (except ts).
EOF

echo "创建 postinst 脚本..."
cat > "$CONTROL_DIR/postinst" << 'EOF'
#!/bin/sh
ldconfig
EOF

echo "设置文件权限..."
find "$PACKAGE_DIR" -type d -exec chmod 755 {} \;
find "$PACKAGE_DIR" -type f -exec chmod 644 {} \;
chmod 755 "$PACKAGE_DIR/usr/local/lib"/*.so*   # .so 文件可执行

# 关键：最后重新设置 postinst 为可执行（覆盖前面的 644）
chmod 755 "$CONTROL_DIR/postinst"

echo "构建 DEB 包..."
cd "$DEB_ROOT_DIR"
dpkg-deb --build "$PACKAGE_NAME"

DEB_FILE="${DEB_ROOT_DIR}/${PACKAGE_NAME}.deb"
echo "DEB 包生成完成：$DEB_FILE"
ls -lh "$DEB_FILE"
echo "SHA256 checksum："
sha256sum "$DEB_FILE"