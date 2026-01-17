#!/usr/bin/env bash

die() {
  log_error "$1"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_sudo() {
  if [ "$EUID" -ne 0 ]; then
    sudo -v || die "sudo is required to continue."
  fi
}

run_cmd() {
  local cmd="$1"
  local needs_root="${2:-0}"
  local exit_code

  log_cmd "$cmd"

  if [ "$needs_root" -eq 1 ] && [ "$EUID" -ne 0 ]; then
    sudo bash -c "$cmd" || exit_code=$?
  else
    bash -c "$cmd" || exit_code=$?
  fi

  if [ -n "${exit_code:-}" ]; then
    log_error "Command failed: $cmd"
    return "$exit_code"
  fi
  return 0
}

confirm() {
  local prompt="$1"
  local reply
  printf "%s [y/N]: " "$prompt"
  read -r reply
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}
