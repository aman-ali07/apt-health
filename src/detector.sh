#!/usr/bin/env bash

detect_dpkg_interrupt() {
  local output
  output="$(dpkg --audit 2>/dev/null || true)"
  if [ -n "$output" ]; then
    log_warn "Interrupted dpkg operations detected."
    printf "%s\n" "$output"
    return 1
  fi
  log_success "No interrupted dpkg operations."
  return 0
}

detect_broken_deps() {
  local output
  if output="$(apt-get check 2>&1)"; then
    log_success "No broken dependencies."
    return 0
  fi
  log_warn "Broken dependencies detected."
  printf "%s\n" "$output"
  return 1
}

detect_locked_apt() {
  local locks=(
    "/var/lib/dpkg/lock"
    "/var/lib/dpkg/lock-frontend"
    "/var/lib/apt/lists/lock"
    "/var/cache/apt/archives/lock"
  )
  local found=0
  local lock

  for lock in "${locks[@]}"; do
    if [ -e "$lock" ]; then
      found=1
      if command_exists fuser && fuser "$lock" >/dev/null 2>&1; then
        log_warn "APT lock active: $lock"
      else
        log_warn "APT lock file present: $lock"
      fi
    fi
  done

  if [ "$found" -eq 0 ]; then
    log_success "No APT locks detected."
    return 0
  fi
  return 1
}

detect_corrupted_cache() {
  local corrupted=0
  local cache_files=(
    "/var/cache/apt/pkgcache.bin"
    "/var/cache/apt/srcpkgcache.bin"
  )

  for file in "${cache_files[@]}"; do
    if [ ! -s "$file" ]; then
      corrupted=1
      log_warn "APT cache file missing or empty: $file"
    fi
  done

  if [ ! -d "/var/lib/apt/lists" ]; then
    corrupted=1
    log_warn "APT lists directory missing: /var/lib/apt/lists"
  else
    local list_count
    list_count="$(find /var/lib/apt/lists -maxdepth 1 -type f 2>/dev/null | wc -l)"
    if [ "$list_count" -eq 0 ]; then
      corrupted=1
      log_warn "APT lists directory appears empty."
    fi
  fi

  if [ "$corrupted" -eq 0 ]; then
    log_success "APT cache looks healthy."
    return 0
  fi
  return 1
}

detect_held_packages() {
  local held
  held="$(apt-mark showhold 2>/dev/null || true)"
  if [ -n "$held" ]; then
    log_warn "Held packages detected."
    printf "%s\n" "$held"
    return 1
  fi
  log_success "No held packages."
  return 0
}

run_all_checks() {
  local failures=0

  detect_dpkg_interrupt || failures=$((failures + 1))
  detect_broken_deps || failures=$((failures + 1))
  detect_locked_apt || failures=$((failures + 1))
  detect_corrupted_cache || failures=$((failures + 1))
  detect_held_packages || failures=$((failures + 1))

  if [ "$failures" -eq 0 ]; then
    log_success "System APT health check passed."
    return 0
  fi
  log_warn "System APT health check reported issues."
  return 1
}
