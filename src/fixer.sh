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
  local update_output
  local update_exit=0
  
  # Capture both stdout and stderr
  if [ "$EUID" -ne 0 ]; then
    update_output="$(sudo apt update 2>&1)" || update_exit=$?
  else
    update_output="$(apt update 2>&1)" || update_exit=$?
  fi
  
  # Show the output
  echo "$update_output"
  log_cmd "apt update"
  
  if [ "$update_exit" -ne 0 ]; then
    # Check if error is due to repository GPG/signing issues
    if echo "$update_output" | grep -qiE "GPG error|NO_PUBKEY|not signed|couldn't be verified"; then
      log_warn "Package list update encountered repository signing issues."
      log_warn "This is usually due to missing GPG keys or unsigned repositories."
      log_warn "Core fixes (dpkg configure, fix-broken) have been applied successfully."
      log_info "To fix repository issues:"
      log_info "  1. Identify the problematic repository from the error above"
      log_info "  2. Add the GPG key: sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <KEY_ID>"
      log_info "  3. Or remove the repository from /etc/apt/sources.list.d/"
      log_info "  4. Then run: sudo apt update"
    else
      log_error "Failed to update package lists."
      return 1
    fi
  fi

  if confirm "Run optional cleanup (apt autoremove --dry-run)?" ; then
    log_info "Performing optional cleanup (dry-run)."
    run_cmd "apt autoremove --dry-run" 1 || true
  else
    log_info "Skipping optional cleanup."
  fi

  log_success "Fix routine completed."
}
