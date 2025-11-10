#!/usr/bin/env bash
set -euo pipefail

# AI Configuration Installer
# Installs AI assistant configuration files from assets/ to system locations
# Supports: Claude Code, Codex CLI, Gemini CLI, OpenCode

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
ASSETS_DIR="$(cd "$SCRIPT_DIR/../assets/ai-configs" && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      cat <<EOF
AI Configuration Installer

Usage: $0

This script installs AI assistant configuration files from the
assets/ai-configs/ directory to their system locations:

  • Claude Code:  ~/.claude/settings.json
  • Codex CLI:    ~/.codex/config.toml
  • Gemini CLI:   ~/.gemini/settings.json
  • OpenCode:     ~/.config/opencode/opencode.json

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

validate_json() {
  local file="$1"
  if command -v jq &>/dev/null; then
    if jq empty "$file" 2>/dev/null; then
      return 0
    else
      log_error "JSON validation failed for $file"
      return 1
    fi
  else
    log_warn "jq not found, skipping JSON validation"
    return 0
  fi
}

validate_toml() {
  local file="$1"
  if command -v python3 &>/dev/null; then
    if python3 -c "import tomllib; tomllib.load(open('$file', 'rb'))" 2>/dev/null; then
      return 0
    else
      log_error "TOML validation failed for $file"
      return 1
    fi
  else
    log_warn "python3 not found, skipping TOML validation"
    return 0
  fi
}

install_config() {
  local source="$1"
  local target="$2"
  local name="$3"
  local validator="$4"

  log_step "Installing: $name"

  if [[ ! -f "$source" ]]; then
    log_error "Source file not found: $source"
    return 1
  fi

  # Validate source file
  if [[ "$validator" == "json" ]]; then
    if ! validate_json "$source"; then
      log_error "Source file validation failed: $name"
      return 1
    fi
  elif [[ "$validator" == "toml" ]]; then
    if ! validate_toml "$source"; then
      log_error "Source file validation failed: $name"
      return 1
    fi
  fi

  # Install config
  mkdir -p "$(dirname "$target")"
  cp "$source" "$target"

  # Validate installed config
  if [[ "$validator" == "json" ]]; then
    if ! validate_json "$target"; then
      log_error "Installed config validation failed: $name"
      return 1
    fi
  elif [[ "$validator" == "toml" ]]; then
    if ! validate_toml "$target"; then
      log_error "Installed config validation failed: $name"
      return 1
    fi
  fi

  log_success "Installed: $name"
}

verify_installation() {
  log_step "Verifying AI configuration installation"

  local errors=0
  local checks=0

  # Check Claude Code config
  checks=$((checks + 1))
  if [[ -f "$HOME/.claude/settings.json" ]]; then
    if validate_json "$HOME/.claude/settings.json" 2>/dev/null; then
      log_success "  ✓ Claude Code settings.json (valid)"
    else
      log_error "  ✗ Claude Code settings.json (invalid JSON)"
      errors=$((errors + 1))
    fi
  else
    log_error "  ✗ Claude Code settings.json - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check Codex config
  checks=$((checks + 1))
  if [[ -f "$HOME/.codex/config.toml" ]]; then
    if validate_toml "$HOME/.codex/config.toml" 2>/dev/null; then
      log_success "  ✓ Codex config.toml (valid)"
    else
      log_error "  ✗ Codex config.toml (invalid TOML)"
      errors=$((errors + 1))
    fi
  else
    log_error "  ✗ Codex config.toml - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check Gemini CLI config
  checks=$((checks + 1))
  if [[ -f "$HOME/.gemini/settings.json" ]]; then
    if validate_json "$HOME/.gemini/settings.json" 2>/dev/null; then
      log_success "  ✓ Gemini settings.json (valid)"
    else
      log_error "  ✗ Gemini settings.json (invalid JSON)"
      errors=$((errors + 1))
    fi
  else
    log_error "  ✗ Gemini settings.json - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check OpenCode config
  checks=$((checks + 1))
  if [[ -f "$HOME/.config/opencode/opencode.json" ]]; then
    if validate_json "$HOME/.config/opencode/opencode.json" 2>/dev/null; then
      log_success "  ✓ OpenCode opencode.json (valid)"
    else
      log_error "  ✗ OpenCode opencode.json (invalid JSON)"
      errors=$((errors + 1))
    fi
  else
    log_error "  ✗ OpenCode opencode.json - NOT FOUND"
    errors=$((errors + 1))
  fi

  printf "\n"
  if [[ $errors -eq 0 ]]; then
    log_success "Verification complete: $checks checks, 0 errors"
    return 0
  else
    log_error "Verification found $errors errors"
    return 1
  fi
}

main() {
  printf "\n${BLUE}═══════════════════════════════════════${NC}\n"
  printf "${BLUE}   AI Configuration Installer${NC}\n"
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

  # Install Claude Code config
  if ! install_config \
    "$ASSETS_DIR/claude-settings.json" \
    "$HOME/.claude/settings.json" \
    "claude-settings.json" \
    "json"; then
    ((failed++))
  fi

  # Install Codex CLI config
  if ! install_config \
    "$ASSETS_DIR/codex-config.toml" \
    "$HOME/.codex/config.toml" \
    "codex-config.toml" \
    "toml"; then
    ((failed++))
  fi

  # Install Gemini CLI config
  if ! install_config \
    "$ASSETS_DIR/gemini-settings.json" \
    "$HOME/.gemini/settings.json" \
    "gemini-settings.json" \
    "json"; then
    ((failed++))
  fi

  # Install OpenCode config
  if ! install_config \
    "$ASSETS_DIR/opencode-config.json" \
    "$HOME/.config/opencode/opencode.json" \
    "opencode-config.json" \
    "json"; then
    ((failed++))
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
    printf "${YELLOW}   Installation Complete with Errors${NC}\n"
  fi
  printf "${GREEN}═══════════════════════════════════════${NC}\n\n"

  if [[ $failed -eq 0 ]]; then
    log_success "All configurations installed successfully"
    printf "\n"
    log_info "Next steps:"
    printf "  ${CYAN}1.${NC} Restart your AI assistants to load new configurations\n"
    printf "  ${CYAN}2.${NC} Verify MCP servers are loading correctly\n"
    printf "  ${CYAN}3.${NC} Check for any errors in AI assistant logs\n"
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
