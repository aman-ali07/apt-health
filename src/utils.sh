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
  local output

  log_cmd "$cmd"

  if [ "$needs_root" -eq 1 ] && [ "$EUID" -ne 0 ]; then
    output="$(sudo bash -c "$cmd" 2>&1)" || exit_code=$?
  else
    output="$(bash -c "$cmd" 2>&1)" || exit_code=$?
  fi

  # Print output (errors go to stderr, normal output to stdout)
  if [ -n "$output" ]; then
    if [ -n "${exit_code:-}" ]; then
      echo "$output" >&2
    else
      echo "$output"
    fi
  fi

  if [ -n "${exit_code:-}" ]; then
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
