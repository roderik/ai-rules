#!/usr/bin/env bash
set -euo pipefail

# Development Tools Installer
# Installs all development tools via Homebrew using Brewfile
# Requires: Homebrew (will attempt to install if missing)

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
BREWFILE="$(cd "$SCRIPT_DIR/../assets" && pwd)/Brewfile"
BREWFILE_MACOS="$(cd "$SCRIPT_DIR/../assets" && pwd)/Brewfile.macos"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      cat <<EOF
Development Tools Installer

Usage: $0

This script installs all development tools using Homebrew and two Brewfiles:
  • Brewfile - Shared CLI tools (cross-platform)
  • Brewfile.macos - macOS-only GUI applications

Shared CLI tools include:
  • Shells (Fish, Zsh, Bash)
  • Modern CLI tools (bat, eza, fd, ripgrep, fzf, jq, yq, btop, etc.)
  • Development tools (git, neovim, node, go, python, etc.)
  • Cloud CLIs (AWS, Azure, GCloud, kubectl, helm, k9s)
  • Terminal tools (tmux, zellij, lazygit, lazydocker)
  • AI CLI tools (gemini-cli, opencode)

macOS-only applications include:
  • Productivity (Raycast, 1Password, Granola, Shottr)
  • Communication (Slack, Zoom, Linear)
  • Development (Cursor, Ghostty, Tower)
  • AI Assistants (Claude, ChatGPT, Codex)

Prerequisites:
  • macOS (Homebrew will be installed if missing)
  • Internet connection

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

detect_os() {
  local OS=$(uname -s)

  case "$OS" in
    Darwin*)
      log_success "macOS detected"
      return 0
      ;;
    Linux*)
      log_success "Linux detected"
      log_info "macOS-specific apps (Brewfile.macos) will be skipped"
      return 0
      ;;
    *)
      log_error "Unsupported operating system: $OS"
      log_error "This script supports macOS and Linux only"
      exit 1
      ;;
  esac
}

install_homebrew() {
  if command -v brew &>/dev/null; then
    log_success "Homebrew already installed"
    return 0
  fi

  log_step "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Detect architecture and add to PATH
  local ARCH=$(uname -m)
  if [[ "$ARCH" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  log_success "Homebrew installed"
}

update_homebrew() {
  log_step "Updating Homebrew"
  brew update
  log_success "Homebrew updated"
}

install_from_brewfile() {
  local brewfile="$1"

  if [[ ! -f "$brewfile" ]]; then
    log_error "Brewfile not found: $brewfile"
    exit 1
  fi

  log_info "Installing from: $(basename "$brewfile")"
  log_info "This may take several minutes..."
  printf "\n"

  # Use brew bundle to install everything
  # Avoid writing Brewfile.lock.json while keeping bundle idempotent
  if HOMEBREW_BUNDLE_NO_LOCK=1 brew bundle --file="$brewfile"; then
    log_success "Completed: $(basename "$brewfile")"
  else
    log_warn "Some tools from $(basename "$brewfile") may have failed to install"
    log_info "Check the output above for details"
    return 1
  fi
}

configure_tools() {
  log_step "Configuring tools"

  # Configure atuin (shell history)
  if command -v atuin &>/dev/null; then
    log_info "Configuring atuin..."
    if brew services list | grep -q "atuin.*started"; then
      log_success "atuin service already running"
    else
      if brew services start atuin 2>/dev/null; then
        log_success "atuin service started"
      else
        log_warn "Could not start atuin service (this is normal on some systems)"
      fi
    fi
  fi

  # Configure git to use modern diff tools
  if command -v difft &>/dev/null && command -v delta &>/dev/null; then
    log_info "Configuring git diff tools..."
    git config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'
    git config --global difftool.prompt false
    git config --global diff.external difft
    git config --global core.pager delta
    log_success "git configured with difftastic and delta"
  fi

  # Create completion directories
  mkdir -p ~/.config/fish/completions
  mkdir -p ~/.config/zsh/completions
  mkdir -p ~/.config/bash/completions

  # Generate completions for tools that support it
  if command -v helm &>/dev/null; then
    log_info "Generating Helm completions..."
    helm completion bash > ~/.config/bash/completions/helm.bash 2>/dev/null || true
    helm completion zsh > ~/.config/zsh/completions/_helm 2>/dev/null || true
    helm completion fish > ~/.config/fish/completions/helm.fish 2>/dev/null || true
    log_success "Helm completions generated"
  fi

  if command -v gh &>/dev/null; then
    log_info "Generating GitHub CLI completions..."
    gh completion -s bash > ~/.config/bash/completions/gh.bash 2>/dev/null || true
    gh completion -s zsh > ~/.config/zsh/completions/_gh 2>/dev/null || true
    gh completion -s fish > ~/.config/fish/completions/gh.fish 2>/dev/null || true
    log_success "GitHub CLI completions generated"
  fi

  # Install @steipete/oracle globally with bun
  if command -v npm &>/dev/null; then
    log_info "Installing @steipete/oracle globally..."
    if npm install -g @steipete/oracle@latest 2>/dev/null; then
      log_success "@steipete/oracle installed globally"
    else
      log_warn "Could not install @steipete/oracle (this may be normal if already installed)"
    fi
    log_info "Installing @steipete/oracle globally..."
    if npm install -g osgrep 2>/dev/null; then
      log_success "osgrep installed globally"
      #osgrep setup
      #osgrep install-claude-code
    else
      log_warn "Could not install osgrep (this may be normal if already installed)"
    fi
  else
    log_warn "npm not found, skipping @steipete/oracle and osgrep installation"
  fi

  log_success "Tool configuration complete"
}

verify_installation() {
  log_step "Verifying installation"

  local errors=0
  local checks=0

  # Core tools to verify
  local core_tools=("fish" "zsh" "bash" "bat" "eza" "fd" "rg" "fzf" "jq" "yq" "git" "gh")
  local dev_tools=("node" "go" "python3" "neovim")
  local cloud_tools=("kubectl" "helm" "awscli")

  # Check core tools
  for tool in "${core_tools[@]}"; do
    checks=$((checks + 1))
    if command -v "$tool" &>/dev/null; then
      log_success "  ✓ $tool"
    else
      log_error "  ✗ $tool - NOT FOUND"
      errors=$((errors + 1))
    fi
  done

  # Check development tools
  for tool in "${dev_tools[@]}"; do
    checks=$((checks + 1))
    if command -v "$tool" &>/dev/null; then
      log_success "  ✓ $tool"
    else
      log_warn "  ⚠ $tool - NOT FOUND (optional)"
    fi
  done

  # Check cloud tools
  for tool in "${cloud_tools[@]}"; do
    checks=$((checks + 1))
    if command -v "$tool" &>/dev/null; then
      log_success "  ✓ $tool"
    else
      log_warn "  ⚠ $tool - NOT FOUND (optional)"
    fi
  done

  printf "\n"
  if [[ $errors -eq 0 ]]; then
    log_success "Verification complete: $checks checks, 0 errors"
    return 0
  else
    log_error "Verification found $errors missing critical tools"
    return 1
  fi
}

main() {
  printf "\n${BLUE}═══════════════════════════════════════${NC}\n"
  printf "${BLUE}   Development Tools Installer${NC}\n"
  printf "${BLUE}═══════════════════════════════════════${NC}\n\n"

  # Detect operating system
  detect_os

  log_info "Shared Brewfile: $BREWFILE"
  log_info "macOS Brewfile: $BREWFILE_MACOS"
  printf "\n"

  # Verify Brewfiles exist
  if [[ ! -f "$BREWFILE" ]]; then
    log_error "Brewfile not found: $BREWFILE"
    log_error "This script must be run from the ai-rules repository"
    exit 1
  fi

  # Only check for Brewfile.macos on macOS
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if [[ ! -f "$BREWFILE_MACOS" ]]; then
      log_error "macOS Brewfile not found: $BREWFILE_MACOS"
      log_error "This script must be run from the ai-rules repository"
      exit 1
    fi
  fi

  # Install/update Homebrew
  install_homebrew
  update_homebrew

  printf "\n"

  # Install shared CLI tools from main Brewfile
  local failed=0
  log_step "Installing shared CLI tools"
  if ! install_from_brewfile "$BREWFILE"; then
    failed=1
  fi

  printf "\n"

  # Install macOS-only applications (skip on Linux)
  if [[ "$(uname -s)" == "Darwin" ]]; then
    log_step "Installing macOS-only applications"
    if ! install_from_brewfile "$BREWFILE_MACOS"; then
      failed=1
    fi
  else
    log_info "Skipping macOS-only applications (not on macOS)"
  fi

  printf "\n"

  # Configure tools
  if ! configure_tools; then
    failed=1
  fi

  printf "\n"

  # Verify installation
  if ! verify_installation; then
    failed=1
  fi

  printf "\n${GREEN}═══════════════════════════════════════${NC}\n"
  if [[ $failed -eq 0 ]]; then
    printf "${GREEN}   Installation Complete!${NC}\n"
  else
    printf "${YELLOW}   Installation Complete with Warnings${NC}\n"
  fi
  printf "${GREEN}═══════════════════════════════════════${NC}\n\n"

  if [[ $failed -eq 0 ]]; then
    log_success "All development tools installed successfully"
    printf "\n"
    log_info "Next steps:"
    printf "  ${CYAN}1.${NC} Install shell configurations: ${YELLOW}bash scripts/install-shell-config.sh${NC}\n"
    printf "  ${CYAN}2.${NC} Install AI configs: ${YELLOW}bash scripts/install-ai-configs.sh${NC}\n"
    printf "  ${CYAN}3.${NC} Restart your terminal to load new tools\n"
  else
    log_warn "Some tools may have failed to install"
    log_info "Check the output above for details"
    log_info "You can re-run this script to retry failed installations"
  fi

  printf "\n"

  if [[ $failed -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
