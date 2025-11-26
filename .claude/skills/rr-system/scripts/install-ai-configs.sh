#!/usr/bin/env bash
set -euo pipefail

# AI Configuration Installer
# Installs AI assistant configuration files from assets/ to system locations
# Supports: Claude Code, Codex CLI, Gemini CLI, OpenCode, Cursor

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

  Config Files:
  • Claude Code:  ~/.claude/settings.json
  • Codex CLI:    ~/.codex/config.toml
  • Gemini CLI:   ~/.gemini/settings.json
  • OpenCode:     ~/.config/opencode/opencode.json
  • Cursor:       ~/.cursor/mcp.json

  Command Files:
  • Claude Code:  ~/.claude/commands/*.md
  • Codex CLI:    ~/.codex/prompts/*.md
  • OpenCode:     ~/.config/opencode/command/*.md

  Agent Instructions:
  • Claude Code:  ~/.claude/CLAUDE.md
  • Codex CLI:    ~/.codex/AGENTS.md
  • Gemini CLI:   ~/.gemini/AGENTS.md
  • OpenCode:     ~/.config/opencode/AGENTS.md

  Agent Files:
  • Claude Code:  ~/.claude/agents/*.md

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

install_commands() {
  local source_dir="$1"
  local target_dir="$2"
  local name="$3"

  log_step "Installing commands: $name"

  if [[ ! -d "$source_dir" ]]; then
    log_error "Source directory not found: $source_dir"
    return 1
  fi

  # Create target directory
  mkdir -p "$target_dir"

  # Clear existing .md files from target directory
  local removed=0
  if [[ -d "$target_dir" ]]; then
    for existing in "$target_dir"/*.md; do
      if [[ -f "$existing" ]]; then
        rm "$existing"
        ((removed++))
      fi
    done
    if [[ $removed -gt 0 ]]; then
      log_info "  Cleared $removed existing command(s)"
    fi
  fi

  # Count files to install
  local file_count=0
  local installed=0
  local failed=0

  # Install all .md files
  for file in "$source_dir"/*.md; do
    if [[ -f "$file" ]]; then
      ((file_count++))
      local basename=$(basename "$file")
      if cp "$file" "$target_dir/$basename"; then
        ((installed++))
      else
        ((failed++))
        log_error "  Failed to install: $basename"
      fi
    fi
  done

  if [[ $file_count -eq 0 ]]; then
    log_warn "  No .md files found in $source_dir"
    return 0
  fi

  if [[ $failed -eq 0 ]]; then
    log_success "  Installed $installed command(s) to $name"
    return 0
  else
    log_error "  Installed $installed/$file_count commands ($failed failed)"
    return 1
  fi
}

install_agents_md() {
  local source="$1"
  local target="$2"
  local name="$3"

  log_step "Installing agent instructions: $name"

  if [[ ! -f "$source" ]]; then
    log_error "Source file not found: $source"
    return 1
  fi

  # Create target directory
  mkdir -p "$(dirname "$target")"

  # Install file
  if cp "$source" "$target"; then
    log_success "  Installed: $(basename "$target")"
    return 0
  else
    log_error "  Failed to install: $(basename "$target")"
    return 1
  fi
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

  # Check Cursor config
  checks=$((checks + 1))
  if [[ -f "$HOME/.cursor/mcp.json" ]]; then
    if validate_json "$HOME/.cursor/mcp.json" 2>/dev/null; then
      log_success "  ✓ Cursor mcp.json (valid)"
    else
      log_error "  ✗ Cursor mcp.json (invalid JSON)"
      errors=$((errors + 1))
    fi
  else
    log_error "  ✗ Cursor mcp.json - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check Claude commands
  checks=$((checks + 1))
  if [[ -d "$HOME/.claude/commands" ]]; then
    local cmd_count=$(find "$HOME/.claude/commands" -name "*.md" 2>/dev/null | wc -l)
    if [[ $cmd_count -gt 0 ]]; then
      log_success "  ✓ Claude commands ($cmd_count found)"
    else
      log_warn "  ⚠ Claude commands directory exists but no commands found"
    fi
  else
    log_error "  ✗ Claude commands directory - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check Codex prompts
  checks=$((checks + 1))
  if [[ -d "$HOME/.codex/prompts" ]]; then
    local prompt_count=$(find "$HOME/.codex/prompts" -name "*.md" 2>/dev/null | wc -l)
    if [[ $prompt_count -gt 0 ]]; then
      log_success "  ✓ Codex prompts ($prompt_count found)"
    else
      log_warn "  ⚠ Codex prompts directory exists but no prompts found"
    fi
  else
    log_error "  ✗ Codex prompts directory - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check OpenCode commands
  checks=$((checks + 1))
  if [[ -d "$HOME/.config/opencode/command" ]]; then
    local oc_cmd_count=$(find "$HOME/.config/opencode/command" -name "*.md" 2>/dev/null | wc -l)
    if [[ $oc_cmd_count -gt 0 ]]; then
      log_success "  ✓ OpenCode commands ($oc_cmd_count found)"
    else
      log_warn "  ⚠ OpenCode command directory exists but no commands found"
    fi
  else
    log_error "  ✗ OpenCode command directory - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check Claude agent instructions
  checks=$((checks + 1))
  if [[ -f "$HOME/.claude/CLAUDE.md" ]]; then
    log_success "  ✓ Claude CLAUDE.md"
  else
    log_error "  ✗ Claude CLAUDE.md - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check Claude agents
  checks=$((checks + 1))
  if [[ -d "$HOME/.claude/agents" ]]; then
    local agent_count=$(find "$HOME/.claude/agents" -name "*.md" 2>/dev/null | wc -l)
    if [[ $agent_count -gt 0 ]]; then
      log_success "  ✓ Claude agents ($agent_count found)"
    else
      log_warn "  ⚠ Claude agents directory exists but no agents found"
    fi
  else
    log_error "  ✗ Claude agents directory - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check Codex agent instructions
  checks=$((checks + 1))
  if [[ -f "$HOME/.codex/AGENTS.md" ]]; then
    log_success "  ✓ Codex AGENTS.md"
  else
    log_error "  ✗ Codex AGENTS.md - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check Gemini agent instructions
  checks=$((checks + 1))
  if [[ -f "$HOME/.gemini/AGENTS.md" ]]; then
    log_success "  ✓ Gemini AGENTS.md"
  else
    log_error "  ✗ Gemini AGENTS.md - NOT FOUND"
    errors=$((errors + 1))
  fi

  # Check OpenCode agent instructions
  checks=$((checks + 1))
  if [[ -f "$HOME/.config/opencode/AGENTS.md" ]]; then
    log_success "  ✓ OpenCode AGENTS.md"
  else
    log_error "  ✗ OpenCode AGENTS.md - NOT FOUND"
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

  # Install Cursor config
  if ! install_config \
    "$ASSETS_DIR/cursor-settings.json" \
    "$HOME/.cursor/mcp.json" \
    "cursor-settings.json" \
    "json"; then
    ((failed++))
  fi

  # Clean up OpenCode plugin caches
  log_step "Cleaning up OpenCode plugin caches"
  if [[ -d "$HOME/.cache/opencode" ]]; then
    if rm -rf "$HOME/.cache/opencode"; then
      log_success "  Cleared OpenCode cache"
    else
      log_warn "  Failed to clear OpenCode cache (may not exist)"
    fi
  else
    log_info "  OpenCode cache directory not found (nothing to clean)"
  fi

  printf "\n"

  # Install commands for all AI tools
  log_info "Installing commands for AI tools"
  printf "\n"

  # Install Claude commands
  if ! install_commands \
    "$ASSETS_DIR/command" \
    "$HOME/.claude/commands" \
    "Claude Code"; then
    ((failed++))
  fi

  # Install Codex prompts
  if ! install_commands \
    "$ASSETS_DIR/command" \
    "$HOME/.codex/prompts" \
    "Codex CLI"; then
    ((failed++))
  fi

  # Install OpenCode commands
  if ! install_commands \
    "$ASSETS_DIR/command" \
    "$HOME/.config/opencode/command" \
    "OpenCode"; then
    ((failed++))
  fi

  printf "\n"

  # Install agent instructions for all AI tools
  log_info "Installing agent instructions for AI tools"
  printf "\n"

  # Install Claude agent instructions (as CLAUDE.md)
  if ! install_agents_md \
    "$ASSETS_DIR/AGENTS.md" \
    "$HOME/.claude/CLAUDE.md" \
    "Claude Code"; then
    ((failed++))
  fi

  # Install Codex agent instructions
  if ! install_agents_md \
    "$ASSETS_DIR/AGENTS.md" \
    "$HOME/.codex/AGENTS.md" \
    "Codex CLI"; then
    ((failed++))
  fi

  # Install Gemini agent instructions
  if ! install_agents_md \
    "$ASSETS_DIR/AGENTS.md" \
    "$HOME/.gemini/AGENTS.md" \
    "Gemini CLI"; then
    ((failed++))
  fi

  # Install OpenCode agent instructions
  if ! install_agents_md \
    "$ASSETS_DIR/AGENTS.md" \
    "$HOME/.config/opencode/AGENTS.md" \
    "OpenCode"; then
    ((failed++))
  fi

  printf "\n"

  # Install Claude agents
  log_info "Installing Claude agents"
  printf "\n"

  if ! install_commands \
    "$ASSETS_DIR/agents" \
    "$HOME/.claude/agents" \
    "Claude Code agents"; then
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
    log_success "All configurations, commands, and agent instructions installed successfully"
    printf "\n"
    log_info "Next steps:"
    printf "  ${CYAN}1.${NC} Restart your AI assistants to load new configurations\n"
    printf "  ${CYAN}2.${NC} Verify MCP servers are loading correctly\n"
    printf "  ${CYAN}3.${NC} Test custom commands are available in each tool\n"
    printf "  ${CYAN}4.${NC} Verify agent instructions are being read (check CLAUDE.md/AGENTS.md)\n"
    printf "  ${CYAN}5.${NC} Check for any errors in AI assistant logs\n"
  else
    log_warn "$failed item(s) failed to install"
    log_info "Check error messages above for details"
  fi

  printf "\n"

  if [[ $failed -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
