# apt-health

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)](https://www.debian.org/)
[![Debian Package](https://img.shields.io/badge/Debian-Package-blue.svg)](https://www.debian.org/distrib/packages)

> A production-ready CLI tool for safely diagnosing and fixing common APT/DPKG issues on Debian-based Linux systems.

## 📋 Overview

`apt-health` is a command-line utility designed to help system administrators and users maintain healthy APT package management systems. It automatically detects common issues such as broken dependencies, interrupted package operations, locked APT processes, and corrupted caches, then applies safe fixes in the correct order.

### ✨ Features

- 🔍 **Comprehensive Diagnostics**: Detects interrupted dpkg operations, broken dependencies, APT locks, corrupted caches, and held packages
- 🛠️ **Safe Automated Fixes**: Applies fixes in the correct order without destructive operations
- 📊 **System Status**: Provides clear overview of APT health and last update timestamps
- 🎨 **Colorized Output**: Easy-to-read terminal output with color-coded messages
- 📝 **Detailed Logging**: All operations logged to `/var/log/apt-health.log`
- 🔒 **Safety First**: No forced removals, no destructive commands, optional cleanup is dry-run only
- ⚡ **Minimal Dependencies**: Only requires `bash`, `apt`, and `dpkg`

## 🚀 Installation

### From APT Repository (Recommended)

```bash
sudo apt update
sudo apt install apt-health
```

### Manual Installation

If you need to install from source or a local `.deb` package:

```bash
# Build the package (recommended)
./build-package.sh

# Install the package
sudo dpkg -i apt-health_1.0.0_amd64.deb
sudo apt-get install -f  # Install dependencies if needed
```

Or use the install script directly (for development):

```bash
sudo ./install.sh
```

## 📖 Usage

### Check System Health

Run a comprehensive health check to identify any APT/DPKG issues:

```bash
apt-health check
```

This command checks for:
- Interrupted dpkg operations
- Broken dependencies
- Active APT locks
- Corrupted package cache
- Held packages

### Apply Safe Fixes

Automatically fix detected issues in the correct order:

```bash
apt-health fix
```

The fix routine performs:
1. Configures pending packages (`dpkg --configure -a`)
2. Fixes broken dependencies (`apt --fix-broken install`)
3. Updates package lists (`apt update`)
4. Optional cleanup preview (dry-run only, with confirmation)

### View System Status

Get a quick overview of your APT system status:

```bash
apt-health status
```

Displays:
- APT lock state
- Count of broken packages
- Last successful update timestamp

### Get Help

```bash
apt-health help
# or
apt-health --help
```

### Check Version

```bash
apt-health version
# or
apt-health --version
```

## 📝 Examples

### Example 1: Routine Health Check

```bash
$ apt-health check
OK No interrupted dpkg operations.
OK No broken dependencies.
OK No APT locks detected.
OK APT cache looks healthy.
OK No held packages.
OK System APT health check passed.
```

### Example 2: Fixing Broken Dependencies

```bash
$ apt-health fix
INFO Configuring pending packages.
INFO Fixing broken dependencies.
INFO Updating package lists.
Run optional cleanup (apt autoremove --dry-run)? [y/N]: n
INFO Skipping optional cleanup.
OK Fix routine completed.
```

### Example 3: System Status

```bash
$ apt-health status
INFO Gathering APT status.
OK APT locks: clear.
INFO Broken packages: 0
INFO Last successful update: 2026-01-17 14:30:22
```

## 🔧 Requirements

- **Operating System**: Debian, Ubuntu, Linux Mint, or other Debian-based distributions
- **Architecture**: amd64
- **Dependencies**:
  - `bash` (>= 4.0)
  - `apt` (>= 1.0)
  - `dpkg` (>= 1.15)
- **Permissions**: Root access (via `sudo`) required for `fix` command

## 📁 File Locations

| Path | Description |
|------|-------------|
| `/usr/bin/apt-health` | Main executable |
| `/usr/lib/apt-health/` | Library scripts |
| `/etc/apt-health/` | Configuration directory |
| `/var/log/apt-health.log` | Log file |

## 🔒 Safety & Security

`apt-health` is designed with safety and security as top priorities:

### Safety Features

- ✅ **No Destructive Commands**: Never removes packages without explicit user confirmation
- ✅ **No Forced Operations**: All fixes are standard APT/DPKG operations
- ✅ **Dry-Run Cleanup**: Optional cleanup operations are preview-only
- ✅ **Safe Order**: Fixes are applied in the correct sequence to avoid conflicts
- ✅ **Error Handling**: Aborts safely on errors, never leaves system half-configured
- ✅ **Comprehensive Logging**: All operations are logged for audit purposes

### Security Considerations

- 🔐 **Log File Permissions**: Log files are created with restricted permissions (0640, root:adm)
- 🔐 **Input Sanitization**: All user input and log messages are sanitized
- 🔐 **Minimal Privileges**: Only requests root access when necessary (fix command)
- 🔐 **No Network Operations**: Tool does not make network connections
- 🔐 **Read-Only Checks**: Most diagnostic operations are read-only and safe
- ⚠️ **Root Access**: The `fix` command requires root privileges via sudo

### When to Use

- After interrupted package installations
- When encountering "broken packages" errors
- Before major system updates
- As part of regular system maintenance
- When troubleshooting APT/DPKG issues

## 📊 Logging

All operations are logged to `/var/log/apt-health.log` with timestamps:

```
2026-01-17T14:30:22Z INFO Gathering APT status.
2026-01-17T14:30:22Z CMD dpkg --audit
2026-01-17T14:30:22Z OK System APT health check passed.
```

Log entries include:
- Timestamp (UTC)
- Log level (INFO, WARN, ERROR, OK)
- Command execution (CMD)
- Operation messages

## 🛠️ Building from Source

See [BUILD.md](BUILD.md) for detailed build instructions.

Quick build:

```bash
# Install dependencies
sudo apt install build-essential dpkg-dev

# Build package (automated)
./build-package.sh

# Test installation
sudo dpkg -i apt-health_1.0.0_amd64.deb
sudo apt-get install -f  # Install dependencies if needed
apt-health version
```

See [BUILD.md](BUILD.md) for detailed build instructions.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Aman**

- GitHub: [@aman-ali07](https://github.com/aman-ali07)

## 🙏 Acknowledgments

- Built for the Debian/Ubuntu community
- Inspired by common APT/DPKG troubleshooting needs
- Follows Debian packaging best practices

## 🔧 Troubleshooting

### Permission Denied Errors

If you see permission errors when running `apt-health check`:

```bash
# Run with sudo for full diagnostics
sudo apt-health check
```

### Log File Issues

If log file creation fails:

```bash
# Manually create log file with correct permissions
sudo touch /var/log/apt-health.log
sudo chmod 0640 /var/log/apt-health.log
sudo chown root:adm /var/log/apt-health.log
```

### Package Installation Issues

If package installation fails:

```bash
# Install missing dependencies
sudo apt-get install -f

# Or install dependencies manually
sudo apt install bash apt dpkg
```

### Build Issues

If the build script fails:

```bash
# Ensure you have build tools
sudo apt install build-essential dpkg-dev

# Check file permissions
chmod +x build-package.sh install.sh
chmod +x DEBIAN/postinst DEBIAN/prerm
```

## 📚 Related Tools

- `apt` - Advanced Package Tool
- `dpkg` - Debian package manager
- `aptitude` - Alternative package manager
- `synaptic` - Graphical package manager

## 🐛 Reporting Issues

Found a bug or have a suggestion? Please open an issue on [GitHub](https://github.com/aman-ali07/apt-health/issues).

---

**Note**: This tool is designed for Debian-based systems. For other distributions, please use the appropriate package manager tools.
