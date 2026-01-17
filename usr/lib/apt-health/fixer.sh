#!/usr/bin/env bash

fix_all() {
  ensure_sudo

  log_info "Configuring pending packages."
  if ! run_cmd "dpkg --configure -a" 1; then
    log_error "Failed to configure pending packages."
    return 1
  fi

  log_info "Fixing broken dependencies."
  if ! run_cmd "apt --fix-broken install -y" 1; then
    log_error "Failed to fix broken dependencies."
    return 1
  fi

  log_info "Updating package lists."
  if ! run_cmd "apt update" 1; then
    log_error "Failed to update package lists."
    return 1
  fi

  if confirm "Run optional cleanup (apt autoremove --dry-run)?" ; then
    log_info "Performing optional cleanup (dry-run)."
    run_cmd "apt autoremove --dry-run" 1 || true
  else
    log_info "Skipping optional cleanup."
  fi

  log_success "Fix routine completed."
}
