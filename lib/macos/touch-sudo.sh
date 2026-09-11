#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/log.sh"

SUDO_LOCAL="/etc/pam.d/sudo_local"

check_sudo() {
    if [ -f "$SUDO_LOCAL" ] && grep -qE "^auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so" "$SUDO_LOCAL"; then
        log_info "Touch ID for sudo already configured."
        return
    fi

    if [ -f "$SUDO_LOCAL" ]; then
        log_step "Adding pam_tid to existing $SUDO_LOCAL"
        printf 'auth       sufficient     pam_tid.so\n' | sudo tee -a "$SUDO_LOCAL" > /dev/null
    else
        log_step "Creating $SUDO_LOCAL"
        sudo tee "$SUDO_LOCAL" > /dev/null <<'EOF'

auth       sufficient     pam_tid.so
EOF
    fi
}

check_sudo
