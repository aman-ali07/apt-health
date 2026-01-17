#!/usr/bin/env bash
set -e

echo "Building apt-health package..."

# Clean previous build
rm -f apt-health_*.deb

# Install files to package structure
./install.sh --root .

# Set permissions
chmod 755 DEBIAN/postinst DEBIAN/prerm
chmod 755 usr/bin/apt-health
chmod 755 usr/lib/apt-health/*.sh

# Create temporary build directory
BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT

# Copy package files (excluding .git and build artifacts)
mkdir -p "$BUILD_DIR/DEBIAN"
cp -r DEBIAN/* "$BUILD_DIR/DEBIAN/"

mkdir -p "$BUILD_DIR/usr/bin"
cp usr/bin/apt-health "$BUILD_DIR/usr/bin/"

mkdir -p "$BUILD_DIR/usr/lib/apt-health"
# Copy library files, excluding any .deb files
for file in usr/lib/apt-health/*; do
  if [ -f "$file" ] && [[ ! "$file" =~ \.deb$ ]]; then
    cp "$file" "$BUILD_DIR/usr/lib/apt-health/"
  fi
done

mkdir -p "$BUILD_DIR/var/log"
touch "$BUILD_DIR/var/log/apt-health.log"

mkdir -p "$BUILD_DIR/etc/apt-health"

# Build package using dpkg-deb with explicit root
cd "$BUILD_DIR"
# Verify structure
ls -la
# Build package - dpkg-deb should not include .deb files it creates
VERSION="1.0.0-1"
dpkg-deb --build . /tmp/apt-health-pkg.deb
# Immediately move it out
mv /tmp/apt-health-pkg.deb "$OLDPWD/apt-health_${VERSION}_amd64.deb"
cd "$OLDPWD"

PACKAGE_NAME="apt-health_${VERSION}_amd64.deb"
echo "Package built: $PACKAGE_NAME"

# Verify
echo ""
echo "Package information:"
dpkg-deb -I "$PACKAGE_NAME"

echo ""
echo "Package contents:"
dpkg-deb -c "$PACKAGE_NAME" | grep -E "^(drwx|-)"

echo ""
echo "Build complete!"
