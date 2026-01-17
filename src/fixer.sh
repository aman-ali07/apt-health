#!/usr/bin/env bash

fix_all() {
  ensure_sudo

  log_info "Configuring pending packages."
  run_cmd "dpkg --configure -a" 1

  log_info "Fixing broken dependencies."
  run_cmd "apt --fix-broken install -y" 1

  log_info "Updating package lists."
  run_cmd "apt update" 1

  if confirm "Run optional cleanup (apt autoremove --dry-run)?" ; then
    log_info "Performing optional cleanup (dry-run)."
    run_cmd "apt autoremove --dry-run" 1
  else
    log_info "Skipping optional cleanup."
  fi

  log_success "Fix routine completed."
}
