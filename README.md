## apt-health

`apt-health` is a production-ready CLI tool for safely diagnosing and fixing
common APT/DPKG issues on Debian-based systems.

### Install

From a published repository:

```bash
sudo apt install apt-health
```

Manual local install:

```bash
sudo ./install.sh
```

### Usage

```bash
apt-health check
apt-health fix
apt-health status
apt-health help
apt-health version
```

### Logs

`apt-health` writes logs to:

```
/var/log/apt-health.log
```

### Safety

- No destructive commands
- No forced removals
- Optional cleanup is dry-run only

# apt-health
