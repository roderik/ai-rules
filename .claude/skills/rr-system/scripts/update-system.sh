#!/usr/bin/env bash
set -euo pipefail

# System Update Script
# Updates shell-config, ai-rules, and wt installations

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { printf "${BLUE}ℹ️  %s${NC}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NC}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NC}\n" "$*" >&2; }

update_homebrew() {
  if command -v brew &>/dev/null; then
    log_info "Updating Homebrew..."
    brew update
    brew upgrade
    log_success "Homebrew updated"
  else
    log_error "Homebrew not found"
  fi
}

update_shell_config() {
  log_info "Updating shell-config..."
  curl -sL https://raw.githubusercontent.com/roderik/shell-config/main/install.sh | bash
  log_success "shell-config updated"
}

update_ai_rules() {
  log_info "Updating ai-rules..."
  curl -sL https://raw.githubusercontent.com/roderik/ai-rules/main/install.sh | bash
  log_success "ai-rules updated"
}

update_wt() {
  log_info "Updating wt..."
  mkdir -p ~/.config/fish/functions
  curl -sL https://raw.githubusercontent.com/roderik/wt/main/wt.fish > ~/.config/fish/functions/wt.fish
  log_success "wt updated"
}

main() {
  printf "\n${BLUE}═══════════════════════════════════════${NC}\n"
  printf "${BLUE}   System Update${NC}\n"
  printf "${BLUE}═══════════════════════════════════════${NC}\n\n"

  update_homebrew
  update_shell_config
  update_ai_rules
  update_wt

  printf "\n${GREEN}═══════════════════════════════════════${NC}\n"
  printf "${GREEN}   Update Complete!${NC}\n"
  printf "${GREEN}═══════════════════════════════════════${NC}\n\n"

  log_info "Restart your terminal to load updates"
}

main "$@"
