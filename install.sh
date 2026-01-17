#!/usr/bin/env bash
set -euo pipefail

ROOT="/"

if [ "${1:-}" = "--root" ]; then
  ROOT="${2:-}"
  shift 2
fi

if [ -z "$ROOT" ]; then
  echo "Root path is required."
  exit 1
fi

ROOT="${ROOT%/}"
if [ -z "$ROOT" ]; then
  ROOT="/"
fi

SUDO=""
if [ "$ROOT" = "/" ] && [ "$EUID" -ne 0 ]; then
  SUDO="sudo"
fi

$SUDO install -d -m 0755 "$ROOT/usr/lib/apt-health"
$SUDO install -d -m 0755 "$ROOT/usr/bin"
$SUDO install -d -m 0755 "$ROOT/etc/apt-health"
$SUDO install -d -m 0755 "$ROOT/var/log"

$SUDO install -m 0755 "src/main.sh" "$ROOT/usr/lib/apt-health/main.sh"
$SUDO install -m 0644 "src/logger.sh" "$ROOT/usr/lib/apt-health/logger.sh"
$SUDO install -m 0644 "src/utils.sh" "$ROOT/usr/lib/apt-health/utils.sh"
$SUDO install -m 0644 "src/detector.sh" "$ROOT/usr/lib/apt-health/detector.sh"
$SUDO install -m 0644 "src/fixer.sh" "$ROOT/usr/lib/apt-health/fixer.sh"

$SUDO tee "$ROOT/usr/bin/apt-health" >/dev/null <<'EOF'
#!/usr/bin/env bash
exec /usr/lib/apt-health/main.sh "$@"
EOF
$SUDO chmod 0755 "$ROOT/usr/bin/apt-health"

$SUDO touch "$ROOT/var/log/apt-health.log"
$SUDO chmod 0644 "$ROOT/var/log/apt-health.log"

echo "apt-health installed to $ROOT"
