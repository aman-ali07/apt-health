#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR"

if [ ! -f "$LIB_DIR/logger.sh" ] && [ -d "/usr/lib/apt-health" ]; then
  LIB_DIR="/usr/lib/apt-health"
fi

source "$LIB_DIR/logger.sh"
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/detector.sh"
source "$LIB_DIR/fixer.sh"

VERSION="1.0.0"

show_help() {
  cat <<'EOF'
apt-health - APT/DPKG diagnostics and safe fixes

Usage:
  apt-health check
  apt-health fix
  apt-health status
  apt-health help
  apt-health version
EOF
}

show_version() {
  printf "apt-health %s\n" "$VERSION"
}

show_status() {
  log_info "Gathering APT status."

  if detect_locked_apt; then
    log_success "APT locks: clear."
  else
    log_warn "APT locks: present."
  fi

  local broken_count
  broken_count="$(dpkg --audit 2>/dev/null | grep -c '^[a-z]' || true)"
  log_info "Broken packages: $broken_count"

  local update_stamp=""
  if [ -f "/var/lib/apt/periodic/update-success-stamp" ]; then
    update_stamp="/var/lib/apt/periodic/update-success-stamp"
  elif [ -f "/var/lib/apt/periodic/apt-get-update-success-stamp" ]; then
    update_stamp="/var/lib/apt/periodic/apt-get-update-success-stamp"
  fi

  if [ -n "$update_stamp" ]; then
    log_info "Last successful update: $(date -r "$update_stamp" "+%Y-%m-%d %H:%M:%S")"
  else
    log_warn "Last successful update: unknown (stamp not found)."
  fi
}

main() {
  local cmd="${1:-help}"
  case "$cmd" in
    check)
      run_all_checks
      ;;
    fix)
      fix_all
      ;;
    status)
      show_status
      ;;
    help|-h|--help)
      show_help
      ;;
    version|-v|--version)
      show_version
      ;;
    *)
      log_error "Unknown command: $cmd"
      show_help
      exit 2
      ;;
  esac
}

main "$@"
