# Build Guide

## Prerequisites

```bash
sudo apt install build-essential dpkg-dev
```

## Package Build Process

### Quick Build (Recommended)

Use the automated build script:

```bash
./build-package.sh
```

This script:
1. Installs files to package structure
2. Sets correct permissions
3. Builds package in clean temporary directory
4. Verifies package contents

### Manual Build Process

#### Step 1: Prepare Package Structure

The package structure should already be in place:
- `src/` - Source scripts
- `DEBIAN/` - Package control files
- `usr/bin/apt-health` - Binary wrapper
- `var/log/apt-health.log` - Log file placeholder

#### Step 2: Install Files to Package Root

```bash
# Install source files to package structure
./install.sh --root .
```

This creates:
- `usr/lib/apt-health/` - Library scripts
- `usr/bin/apt-health` - Already exists, will be overwritten
- `var/log/apt-health.log` - Already exists

#### Step 3: Set Permissions

```bash
chmod 755 DEBIAN/postinst DEBIAN/prerm
chmod 755 usr/bin/apt-health
chmod 755 usr/lib/apt-health/*.sh
```

#### Step 4: Build Debian Package

**Important**: Build in a clean directory to avoid including .git and other files.

```bash
# Create temporary build directory
BUILD_DIR=$(mktemp -d)
cp -r DEBIAN usr var etc "$BUILD_DIR/"
cd "$BUILD_DIR"
dpkg-deb --build . apt-health_1.0.0_amd64.deb
mv apt-health_1.0.0_amd64.deb /path/to/apt-health/
cd -
rm -rf "$BUILD_DIR"
```

#### Step 5: Verify Package

```bash
# Check package contents
dpkg-deb -c apt-health_1.0.0_amd64.deb

# Check package information
dpkg-deb -I apt-health_1.0.0_amd64.deb
```

## Installation

### Install from .deb file

```bash
sudo dpkg -i apt-health_1.0.0_amd64.deb
```

If dependencies are missing:

```bash
sudo apt-get install -f
```

### Test Installation

```bash
apt-health version
apt-health help
apt-health check
```

## Cleanup Staging Files

After building, clean up staging directories:

```bash
rm -rf usr/lib usr/bin var/log
```

**Note**: Keep `DEBIAN/` directory for future builds.

## Complete Build Script

```bash
#!/bin/bash
set -e

echo "Building apt-health package..."

# Install files
./install.sh --root .

# Set permissions
chmod 755 DEBIAN/postinst DEBIAN/prerm
chmod 755 usr/bin/apt-health
chmod 755 usr/lib/apt-health/*.sh

# Build package
dpkg-deb --build . apt-health_1.0.0_amd64.deb

echo "Package built: apt-health_1.0.0_amd64.deb"

# Verify
dpkg-deb -I apt-health_1.0.0_amd64.deb

echo "Build complete!"
```

## Publishing to GitHub Releases

1. Create a release tag:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. Upload `apt-health_1.0.0_amd64.deb` to GitHub Releases

3. Users can install via:
   ```bash
   wget https://github.com/aman-ali07/apt-health/releases/download/v1.0.0/apt-health_1.0.0_amd64.deb
   sudo dpkg -i apt-health_1.0.0_amd64.deb
   sudo apt-get install -f
   ```
