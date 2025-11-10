#!/usr/bin/env bash
set -euo pipefail

# Ubuntu/Debian System Setup Script
# Installs shell-config, ai-rules, and wt for apt-based systems

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { printf "${BLUE}ℹ️  %s${NC}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NC}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NC}\n" "$*" >&2; }
log_warning() { printf "${YELLOW}⚠️  %s${NC}\n" "$*"; }

check_ubuntu() {
  if [[ ! -f /etc/os-release ]]; then
    log_error "Cannot detect OS. This script is for Ubuntu/Debian. Use install-macos.sh for macOS."
    exit 1
  fi

  if grep -qE "Ubuntu|Debian" /etc/os-release; then
    local distro=$(grep -oP '(?<=^NAME=").+(?=")' /etc/os-release || echo "Linux")
    log_success "$distro detected"
  else
    log_error "This script is for Ubuntu/Debian only. Use install-macos.sh for macOS."
    exit 1
  fi
}

install_base_tools() {
  log_info "Installing base development tools..."

  sudo apt-get update
  sudo apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    unzip \
    software-properties-common

  log_success "Base tools installed"
}

install_homebrew() {
  if command -v brew &>/dev/null; then
    log_success "Homebrew already installed"
    log_info "Updating Homebrew..."
    brew update
  else
    log_info "Installing Homebrew for Linux..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc

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

configure_shells() {
  log_info "Configuring shell permissions..."

  # Add shells to /etc/shells if not already present
  local FISH_PATH=$(command -v fish || echo "")
  local ZSH_PATH=$(command -v zsh || echo "")

  if [[ -n "$FISH_PATH" ]] && ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    log_success "Fish added to /etc/shells"
  fi

  if [[ -n "$ZSH_PATH" ]] && ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    log_success "Zsh added to /etc/shells"
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
  printf "${BLUE}   Ubuntu/Debian Development Setup${NC}\n"
  printf "${BLUE}═══════════════════════════════════════${NC}\n\n"

  check_ubuntu
  install_base_tools
  install_homebrew
  install_shell_config
  install_ai_rules
  install_wt
  configure_shells
  verify_installation

  printf "\n${GREEN}═══════════════════════════════════════${NC}\n"
  printf "${GREEN}   Installation Complete!${NC}\n"
  printf "${GREEN}═══════════════════════════════════════${NC}\n\n"

  log_info "Next steps:"
  echo "  1. Restart your terminal or run: source ~/.bashrc"
  echo "  2. Run: fish (to start Fish shell)"
  echo "  3. Run: wt help (to verify wt installation)"
  echo ""
}

main "$@"
