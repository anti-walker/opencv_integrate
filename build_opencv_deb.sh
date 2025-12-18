#!/bin/bash
set -e  # exit on error

# ================ User Manual ================
if [ $# -ne 3 ]; then
    echo "use: $0 <OPENCV_SO_DIR> <DEB_ROOT_DIR> <PACKAGE_NAME>"
    echo "ex:"
    echo "  $0 /home/user/copy_opencv_libs/opencv_x86 ~/deb_build opencv_x86_badp"
    echo "  $0 /home/user/copy_opencv_libs/opencv_arm64 ~/deb_build opencv_arm64_badp"
    exit 1
fi

# ================ Params ================
OPENCV_SO_DIR="$1"      # directory of opencv*.so files
DEB_ROOT_DIR="$2"       # DEB build root directory
PACKAGE_NAME="$3"       # package name, e.g., opencv_x86_badp

VERSION="4.10.0-1"
PACKAGE_DIR="${DEB_ROOT_DIR}/${PACKAGE_NAME}"
CONTROL_DIR="${PACKAGE_DIR}/DEBIAN"

# ================ Params validation ================
if [ ! -d "$OPENCV_SO_DIR" ]; then
    echo "error: OPENCV_SO_DIR not exists -> $OPENCV_SO_DIR"
    exit 1
fi

# ================ begin to package ================
echo "begin to package OpenCV DEB..."
echo "so dir: $OPENCV_SO_DIR"
echo "build dir: $DEB_ROOT_DIR"
echo "package name: $PACKAGE_NAME"
echo

# 1. clear and create necessary directories
rm -rf "$DEB_ROOT_DIR"
mkdir -p "$PACKAGE_DIR/usr/local"
mkdir -p "$CONTROL_DIR"

# 2. copy OpenCV so files to /usr/local/
echo "copy OpenCV files..."
cp -r "$OPENCV_SO_DIR"/* "$PACKAGE_DIR/usr/local/"

# 3. create control file
echo "create control file..."
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

# 4. create postinst script (update ldconfig after installation)
echo "create postinst script..."
cat > "$CONTROL_DIR/postinst" << 'EOF'
#!/bin/sh
ldconfig
EOF

# 5. set file permissions
echo "set file permissions..."
find "$PACKAGE_DIR" -type d -exec chmod 755 {} \;
find "$PACKAGE_DIR" -type f -exec chmod 644 {} \;
chmod 755 "$PACKAGE_DIR/usr/local/lib"/*.so*  # shared libraries should be executable

# set postinst script as executable
chmod 755 "$CONTROL_DIR/postinst"

# 6. build DEB package
echo "build DEB package..."
cd "$DEB_ROOT_DIR"
dpkg-deb --build "$PACKAGE_NAME"

# 7. final output
DEB_FILE="${DEB_ROOT_DIR}/${PACKAGE_NAME}.deb"
echo
echo "DEB package built successfully: $DEB_FILE"
ls -lh "$DEB_FILE"
echo "SHA256 checksum:"
sha256sum "$DEB_FILE"