#!/usr/bin/env bash
set -euo pipefail

# Shell Configuration Installer
# Installs shell configuration files for Fish, Zsh, Bash, Starship, and Ghostty
# from assets/shell-config to system locations

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { printf "${BLUE}ℹ️  %s${NC}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NC}\n" "$*"; }
log_warn() { printf "${YELLOW}⚠️  %s${NC}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NC}\n" "$*" >&2; }
log_step() { printf "${CYAN}▶  %s${NC}\n" "$*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$(cd "$SCRIPT_DIR/../assets/shell-config" && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      cat <<EOF
Shell Configuration Installer

Usage: $0

This script installs shell configuration files from the
assets/shell-config/ directory to their system locations:

Fish Shell:
  • ~/.config/fish/config.fish
  • ~/.config/fish/conf.d/*.fish
  • ~/.config/fish/functions/*.fish (including wt.fish)

Zsh:
  • ~/.zshrc
  • ~/.config/zsh/conf.d/*.zsh

Bash:
  • ~/.bashrc
  • ~/.bash_profile (if exists)
  • ~/.config/bash/conf.d/*.bash

Starship:
  • ~/.config/starship.toml

Ghostty:
  • ~/Library/Application Support/com.mitchellh.ghostty/config

Existing configurations will be overwritten with the latest versions.

EOF
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      log_info "Use --help for usage information"
      exit 1
      ;;
  esac
done

install_fish_config() {
  local config_base="$1"

  if [[ ! -d "$config_base/fish" ]]; then
    log_warn "Fish config not found in assets, skipping"
    return 0
  fi

  log_step "Installing Fish configuration"

  # Create directories
  mkdir -p ~/.config/fish/conf.d
  mkdir -p ~/.config/fish/functions

  # Install main config
  if [ -f "$config_base/fish/config.fish" ]; then
    cp "$config_base/fish/config.fish" ~/.config/fish/config.fish
    log_success "  → config.fish"
  fi

  # Install conf.d modules
  if [ -d "$config_base/fish/conf.d" ]; then
    find "$config_base/fish/conf.d" -name "*.fish" -type f | sort | while read conf_file; do
      local conf_name=$(basename "$conf_file")
      cp "$conf_file" ~/.config/fish/conf.d/"$conf_name"
      log_success "  → conf.d/$conf_name"
    done
  fi

  # Install functions
  if [ -d "$config_base/fish/functions" ]; then
    find "$config_base/fish/functions" -name "*.fish" -type f | sort | while read func_file; do
      local func_name=$(basename "$func_file")
      cp "$func_file" ~/.config/fish/functions/"$func_name"
      log_success "  → functions/$func_name"
    done
  fi
}

install_zsh_config() {
  local config_base="$1"

  if [[ ! -d "$config_base/zsh" ]]; then
    log_warn "Zsh config not found in assets, skipping"
    return 0
  fi

  log_step "Installing Zsh configuration"

  # Create directories
  mkdir -p ~/.config/zsh/conf.d

  # Install main .zshrc (if exists in assets)
  if [ -f "$config_base/zsh/.zshrc" ]; then
    cp "$config_base/zsh/.zshrc" ~/.zshrc
    log_success "  → .zshrc"
  fi

  # Install conf.d modules
  if [ -d "$config_base/zsh/conf.d" ]; then
    find "$config_base/zsh/conf.d" -name "*.zsh" -type f | sort | while read conf_file; do
      local conf_name=$(basename "$conf_file")
      cp "$conf_file" ~/.config/zsh/conf.d/"$conf_name"
      log_success "  → conf.d/$conf_name"
    done
  fi
}

install_bash_config() {
  local config_base="$1"

  if [[ ! -d "$config_base/bash" ]]; then
    log_warn "Bash config not found in assets, skipping"
    return 0
  fi

  log_step "Installing Bash configuration"

  # Create directories
  mkdir -p ~/.config/bash/conf.d

  # Install .bashrc (if exists)
  if [ -f "$config_base/bash/.bashrc" ]; then
    cp "$config_base/bash/.bashrc" ~/.bashrc
    log_success "  → .bashrc"
  fi

  # Install .bash_profile (if exists)
  if [ -f "$config_base/bash/.bash_profile" ]; then
    cp "$config_base/bash/.bash_profile" ~/.bash_profile
    log_success "  → .bash_profile"
  fi

  # Install conf.d modules
  if [ -d "$config_base/bash/conf.d" ]; then
    find "$config_base/bash/conf.d" -name "*.bash" -type f | sort | while read conf_file; do
      local conf_name=$(basename "$conf_file")
      cp "$conf_file" ~/.config/bash/conf.d/"$conf_name"
      log_success "  → conf.d/$conf_name"
    done
  fi
}

install_starship_config() {
  local config_base="$1"

  if [ ! -f "$config_base/starship/starship.toml" ]; then
    log_warn "Starship config not found in assets, skipping"
    return 0
  fi

  log_step "Installing Starship configuration"

  mkdir -p ~/.config
  cp "$config_base/starship/starship.toml" ~/.config/starship.toml
  log_success "  → starship.toml"
}

install_ghostty_config() {
  local config_base="$1"

  if [ ! -f "$config_base/ghostty/config" ]; then
    log_warn "Ghostty config not found in assets, skipping"
    return 0
  fi

  log_step "Installing Ghostty configuration"

  local target_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$target_dir"
  cp "$config_base/ghostty/config" "$target_dir/config"
  log_success "  → Ghostty config"
}

configure_sudo_touchid() {
  log_step "Configuring Touch ID for sudo (macOS only)"

  if [[ "$(uname -s)" != "Darwin" ]]; then
    log_info "Skipping - not macOS"
    return 0
  fi

  if [[ ! -f /etc/pam.d/sudo_local.template ]]; then
    log_warn "sudo_local.template not found, skipping Touch ID configuration"
    return 0
  fi

  log_info "Enabling Touch ID for sudo (requires sudo password)..."
  if sudo sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local > /dev/null; then
    log_success "Touch ID enabled for sudo"
  else
    log_warn "Could not enable Touch ID for sudo"
  fi
}

register_shells() {
  log_step "Registering shells in /etc/shells"

  # Detect architecture
  local ARCH=$(uname -m)
  local FISH_PATH ZSH_PATH

  if [[ "$ARCH" == "arm64" ]]; then
    FISH_PATH="/opt/homebrew/bin/fish"
    ZSH_PATH="/opt/homebrew/bin/zsh"
  else
    FISH_PATH="/usr/local/bin/fish"
    ZSH_PATH="/usr/local/bin/zsh"
  fi

  # Register Fish
  if [[ -f "$FISH_PATH" ]]; then
    if grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
      log_success "Fish already registered in /etc/shells"
    else
      log_info "Adding Fish to /etc/shells (requires sudo)..."
      echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
      log_success "Fish registered in /etc/shells"
    fi
  fi

  # Register Zsh
  if [[ -f "$ZSH_PATH" ]]; then
    if grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
      log_success "Zsh already registered in /etc/shells"
    else
      log_info "Adding Zsh to /etc/shells (requires sudo)..."
      echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
      log_success "Zsh registered in /etc/shells"
    fi
  fi
}

fix_zsh_permissions() {
  log_step "Fixing Zsh completion directory permissions"

  if ! command -v zsh &>/dev/null; then
    log_info "Zsh not installed, skipping"
    return 0
  fi

  # Fix Homebrew directories
  if [[ -d /opt/homebrew/share ]]; then
    log_info "Fixing Apple Silicon Homebrew permissions (requires sudo)..."
    sudo chown -R $USER /opt/homebrew/share /opt/homebrew/share/zsh /opt/homebrew/share/zsh/site-functions 2>/dev/null || true
    chmod u+w /opt/homebrew/share /opt/homebrew/share/zsh /opt/homebrew/share/zsh/site-functions 2>/dev/null || true
  fi

  if [[ -d /usr/local/share ]]; then
    log_info "Fixing Intel Homebrew permissions (requires sudo)..."
    sudo chown -R $USER /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions 2>/dev/null || true
    chmod u+w /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions 2>/dev/null || true
  fi

  # Fix user directories
  if [[ -d ~/.config/zsh ]]; then
    chmod 755 ~/.config/zsh 2>/dev/null || true
    chmod 755 ~/.config/zsh/conf.d 2>/dev/null || true
    chmod 755 ~/.config/zsh/completions 2>/dev/null || true
  fi

  # Check for remaining insecure directories
  local insecure_dirs=$(zsh -c 'compaudit' 2>/dev/null || true)

  if [[ -n "$insecure_dirs" ]]; then
    log_info "Fixing remaining insecure directories..."
    echo "$insecure_dirs" | while IFS= read -r dir; do
      if [[ -n "$dir" ]] && [[ -d "$dir" ]]; then
        if [[ "$dir" == /opt/* ]] || [[ "$dir" == /usr/* ]]; then
          sudo chown -R $USER "$dir" 2>/dev/null && chmod u+w "$dir" 2>/dev/null && \
          log_success "  → Fixed: $dir"
        else
          chmod 755 "$dir" 2>/dev/null && log_success "  → Fixed: $dir"
        fi
      fi
    done

    # Verify fix
    local remaining=$(zsh -c 'compaudit' 2>/dev/null || true)
    if [[ -z "$remaining" ]]; then
      log_success "All Zsh directories secured"
    else
      log_warn "Some directories may still need attention"
      log_info "Run 'compaudit' manually to check"
    fi
  else
    log_success "All Zsh directories already secured"
  fi
}

verify_installation() {
  log_step "Verifying shell configuration installation"

  local errors=0
  local checks=0

  # Check Fish configuration
  checks=$((checks + 1))
  if [[ -f ~/.config/fish/config.fish ]]; then
    log_success "  ✓ Fish config.fish"
  else
    log_error "  ✗ Fish config.fish - NOT FOUND"
    errors=$((errors + 1))
  fi

  checks=$((checks + 1))
  if [[ -d ~/.config/fish/conf.d ]] && [[ -n $(ls -A ~/.config/fish/conf.d 2>/dev/null) ]]; then
    local count=$(ls ~/.config/fish/conf.d/*.fish 2>/dev/null | wc -l | tr -d ' ')
    log_success "  ✓ Fish conf.d ($count modules)"
  else
    log_warn "  ⚠ Fish conf.d - EMPTY OR MISSING"
  fi

  checks=$((checks + 1))
  if [[ -f ~/.config/fish/functions/wt.fish ]]; then
    log_success "  ✓ Fish wt.fish function"
  else
    log_warn "  ⚠ Fish wt.fish - NOT FOUND"
  fi

  # Check Zsh configuration
  checks=$((checks + 1))
  if [[ -f ~/.zshrc ]]; then
    log_success "  ✓ Zsh .zshrc"
  else
    log_error "  ✗ Zsh .zshrc - NOT FOUND"
    errors=$((errors + 1))
  fi

  checks=$((checks + 1))
  if [[ -d ~/.config/zsh/conf.d ]] && [[ -n $(ls -A ~/.config/zsh/conf.d 2>/dev/null) ]]; then
    local count=$(ls ~/.config/zsh/conf.d/*.zsh 2>/dev/null | wc -l | tr -d ' ')
    log_success "  ✓ Zsh conf.d ($count modules)"
  else
    log_warn "  ⚠ Zsh conf.d - EMPTY OR MISSING"
  fi

  # Check Bash configuration
  checks=$((checks + 1))
  if [[ -f ~/.bashrc ]]; then
    log_success "  ✓ Bash .bashrc"
  else
    log_error "  ✗ Bash .bashrc - NOT FOUND"
    errors=$((errors + 1))
  fi

  checks=$((checks + 1))
  if [[ -f ~/.bash_profile ]]; then
    log_success "  ✓ Bash .bash_profile"
  else
    log_warn "  ⚠ Bash .bash_profile - NOT FOUND"
  fi

  # Check Starship configuration
  checks=$((checks + 1))
  if [[ -f ~/.config/starship.toml ]]; then
    log_success "  ✓ Starship configuration"
  else
    log_warn "  ⚠ Starship configuration - NOT FOUND"
  fi

  # Check Ghostty configuration (macOS only)
  checks=$((checks + 1))
  if [[ -f "$HOME/Library/Application Support/com.mitchellh.ghostty/config" ]]; then
    log_success "  ✓ Ghostty configuration"
  else
    log_warn "  ⚠ Ghostty configuration - NOT FOUND"
  fi

  printf "\n"
  if [[ $errors -eq 0 ]]; then
    log_success "Verification complete: $checks checks, 0 errors"
    return 0
  else
    log_error "Verification found $errors missing critical files"
    return 1
  fi
}

main() {
  printf "\n${BLUE}═══════════════════════════════════════${NC}\n"
  printf "${BLUE}   Shell Configuration Installer${NC}\n"
  printf "${BLUE}═══════════════════════════════════════${NC}\n\n"

  log_info "Assets directory: $ASSETS_DIR"
  printf "\n"

  # Verify assets directory exists
  if [[ ! -d "$ASSETS_DIR" ]]; then
    log_error "Assets directory not found: $ASSETS_DIR"
    log_error "This script must be run from the ai-rules repository"
    exit 1
  fi

  local failed=0

  # Install all configurations
  install_fish_config "$ASSETS_DIR" || ((failed++))
  install_zsh_config "$ASSETS_DIR" || ((failed++))
  install_bash_config "$ASSETS_DIR" || ((failed++))
  install_starship_config "$ASSETS_DIR" || ((failed++))
  install_ghostty_config "$ASSETS_DIR" || ((failed++))

  printf "\n"

  # System configuration
  configure_sudo_touchid || ((failed++))
  printf "\n"
  register_shells || ((failed++))
  printf "\n"
  fix_zsh_permissions || ((failed++))

  printf "\n"

  # Verify installation
  if ! verify_installation; then
    failed=1
  fi

  printf "\n${GREEN}═══════════════════════════════════════${NC}\n"
  if [[ $failed -eq 0 ]]; then
    printf "${GREEN}   Installation Complete!${NC}\n"
  else
    printf "${YELLOW}   Installation Complete with Errors${NC}\n"
  fi
  printf "${GREEN}═══════════════════════════════════════${NC}\n\n"

  if [[ $failed -eq 0 ]]; then
    log_success "All configurations installed successfully"
    printf "\n"
    log_info "Next steps:"
    printf "  ${CYAN}1.${NC} Restart your terminal to load new shell configurations\n"
    printf "  ${CYAN}2.${NC} To use Fish shell: ${YELLOW}fish${NC}\n"
    printf "  ${CYAN}3.${NC} To use Zsh: ${YELLOW}zsh${NC}\n"
    printf "  ${CYAN}4.${NC} To make a shell default: ${YELLOW}chsh -s \$(which fish)${NC}\n"
  else
    log_warn "$failed configuration(s) failed to install"
    log_info "Check error messages above for details"
  fi

  printf "\n"

  if [[ $failed -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
