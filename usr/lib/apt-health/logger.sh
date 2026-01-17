#!/usr/bin/env bash

LOG_FILE="/var/log/apt-health.log"

COLOR_RESET="\033[0m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_GREEN="\033[32m"
COLOR_BLUE="\033[34m"

log_line() {
  # Always log to file; use sudo if needed
  local message="$1"
  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  if [ -w "$LOG_FILE" ]; then
    printf "%s %s\n" "$timestamp" "$message" >> "$LOG_FILE"
  else
    printf "%s %s\n" "$timestamp" "$message" | sudo tee -a "$LOG_FILE" >/dev/null
  fi
}

log_info() {
  printf "%bINFO%b %s\n" "$COLOR_BLUE" "$COLOR_RESET" "$1"
  log_line "INFO $1"
}

log_warn() {
  printf "%bWARN%b %s\n" "$COLOR_YELLOW" "$COLOR_RESET" "$1"
  log_line "WARN $1"
}

log_error() {
  printf "%bERROR%b %s\n" "$COLOR_RED" "$COLOR_RESET" "$1"
  log_line "ERROR $1"
}

log_success() {
  printf "%bOK%b %s\n" "$COLOR_GREEN" "$COLOR_RESET" "$1"
  log_line "OK $1"
}

log_cmd() {
  log_line "CMD $1"
}
