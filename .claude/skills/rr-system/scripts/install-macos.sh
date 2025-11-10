#!/usr/bin/env bash
set -euo pipefail

# macOS System Setup Script
# Installs shell-config, ai-rules, and wt for macOS systems

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { printf "${BLUE}ℹ️  %s${NC}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NC}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NC}\n" "$*" >&2; }
log_warning() { printf "${YELLOW}⚠️  %s${NC}\n" "$*"; }

check_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log_error "This script is for macOS only. Use install-ubuntu.sh for Ubuntu."
    exit 1
  fi
  log_success "macOS detected"
}

install_xcode_cli() {
  if xcode-select -p &>/dev/null; then
    log_success "Xcode Command Line Tools already installed"
  else
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    read -p "Press enter after Xcode CLI tools installation completes..."
    log_success "Xcode Command Line Tools installed"
  fi
}

install_homebrew() {
  if command -v brew &>/dev/null; then
    log_success "Homebrew already installed"
    log_info "Updating Homebrew..."
    brew update
  else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    local ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    log_success "Homebrew installed"
  fi
}

install_shell_config() {
  log_info "Installing shell-config from https://github.com/roderik/shell-config"

  local temp_dir=$(mktemp -d)
  cd "$temp_dir"

  if git clone https://github.com/roderik/shell-config.git; then
    cd shell-config
    ./install.sh
    log_success "shell-config installed"
  else
    log_error "Failed to clone shell-config repository"
    exit 1
  fi

  cd ~
  rm -rf "$temp_dir"
}

install_ai_rules() {
  log_info "Installing ai-rules from https://github.com/roderik/ai-rules"

  local temp_dir=$(mktemp -d)
  cd "$temp_dir"

  if git clone https://github.com/roderik/ai-rules.git; then
    cd ai-rules
    ./install.sh
    log_success "ai-rules installed"
  else
    log_error "Failed to clone ai-rules repository"
    exit 1
  fi

  cd ~
  rm -rf "$temp_dir"
}

install_wt() {
  log_info "Installing wt from https://github.com/roderik/wt"

  mkdir -p ~/.config/fish/functions

  if curl -sL https://raw.githubusercontent.com/roderik/wt/main/wt.fish > ~/.config/fish/functions/wt.fish; then
    log_success "wt installed"
  else
    log_error "Failed to download wt"
    exit 1
  fi
}

verify_installation() {
  log_info "Verifying installation..."

  local errors=0

  if ! command -v brew &>/dev/null; then
    log_error "Homebrew not found in PATH"
    errors=$((errors + 1))
  fi

  if [[ ! -f ~/.config/fish/config.fish ]]; then
    log_warning "Fish config not found (expected if shell-config failed)"
    errors=$((errors + 1))
  fi

  if [[ ! -f ~/.claude/settings.json ]] && [[ ! -d ~/.claude ]]; then
    log_warning "Claude config not found (expected if ai-rules failed)"
    errors=$((errors + 1))
  fi

  if [[ ! -f ~/.config/fish/functions/wt.fish ]]; then
    log_error "wt not found"
    errors=$((errors + 1))
  fi

  if [[ $errors -eq 0 ]]; then
    log_success "All components verified successfully"
  else
    log_warning "$errors component(s) failed verification"
  fi
}

main() {
  printf "\n${BLUE}═══════════════════════════════════════${NC}\n"
  printf "${BLUE}   macOS Development Setup${NC}\n"
  printf "${BLUE}═══════════════════════════════════════${NC}\n\n"

  check_macos
  install_xcode_cli
  install_homebrew
  install_shell_config
  install_ai_rules
  install_wt
  verify_installation

  printf "\n${GREEN}═══════════════════════════════════════${NC}\n"
  printf "${GREEN}   Installation Complete!${NC}\n"
  printf "${GREEN}═══════════════════════════════════════${NC}\n\n"

  log_info "Next steps:"
  echo "  1. Restart your terminal or run: source ~/.config/fish/config.fish"
  echo "  2. Run: fish (to start Fish shell)"
  echo "  3. Run: wt help (to verify wt installation)"
  echo ""
}

main "$@"
