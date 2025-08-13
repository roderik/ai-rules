#!/usr/bin/env bash

set -euo pipefail

# AI Rules uninstaller for Claude Code and Claude Desktop
# Removes AI Rules configurations while preserving user settings

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Emoji indicators
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"
TRASH="🗑️"

# Print colored output
print_color() {
  local color=$1
  shift
  printf "${color}%s${NC}\n" "$*"
}

# Print status messages
log_success() { printf "${GREEN}${SUCCESS} %s${NC}\n" "$*"; }
log_error() { printf "${RED}${ERROR} %s${NC}\n" "$*" >&2; }
log_warning() { printf "${YELLOW}${WARNING} %s${NC}\n" "$*"; }
log_info() { printf "${CYAN}${INFO} %s${NC}\n" "$*"; }

# Display uninstall banner
show_banner() {
  printf "\n"
  printf "${BLUE}     █████${CYAN}╗ ██${GREEN}╗    ██████${YELLOW}╗ ██${MAGENTA}╗   ██${RED}╗██${BLUE}╗     ███████${CYAN}╗███████${GREEN}╗${NC}\n"
  printf "${BLUE}    ██${CYAN}╔══██╗██${GREEN}║    ██${YELLOW}╔══██╗██${MAGENTA}║   ██${RED}║██${BLUE}║     ██${CYAN}╔════╝██${GREEN}╔════╝${NC}\n"
  printf "${BLUE}    ███████${CYAN}║██${GREEN}║    ██████${YELLOW}╔╝██${MAGENTA}║   ██${RED}║██${BLUE}║     █████${CYAN}╗  ███████${GREEN}╗${NC}\n"
  printf "${BLUE}    ██${CYAN}╔══██║██${GREEN}║    ██${YELLOW}╔══██╗██${MAGENTA}║   ██${RED}║██${BLUE}║     ██${CYAN}╔══╝  ╚════██${GREEN}║${NC}\n"
  printf "${BLUE}    ██${CYAN}║  ██║██${GREEN}║    ██${YELLOW}║  ██║╚██████${MAGENTA}╔╝███████${RED}╗███████${BLUE}╗███████${CYAN}║${NC}\n"
  printf "${BLUE}    ╚═${CYAN}╝  ╚═╝╚═${GREEN}╝    ╚═${YELLOW}╝  ╚═╝ ╚═════${MAGENTA}╝ ╚══════${RED}╝╚══════${BLUE}╝╚══════${CYAN}╝${NC}\n"
  printf "\n"
  printf "${BOLD}${RED}                    ╔═══════════════════════════╗${NC}\n"
  printf "${BOLD}${YELLOW}                    ║   AI Rules Uninstaller    ║${NC}\n"
  printf "${BOLD}${RED}                    ╚═══════════════════════════╝${NC}\n"
  printf "\n"
}

# Check for required dependencies
check_dependencies() {
  if ! command -v jq >/dev/null 2>&1; then
    log_error "jq is required for uninstallation"
    log_info "Please install jq and try again."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
      log_info "On macOS: brew install jq"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      log_info "On Linux: use your package manager (apt, yum, etc.)"
    fi
    exit 1
  fi
}

# Prompt for confirmation
confirm_uninstall() {
  printf "\n"
  print_color "$YELLOW" "This will remove AI Rules configurations from:"
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    print_color "$CYAN" "  • Claude Code: %USERPROFILE%\\.claude\\"
  else
    print_color "$CYAN" "  • Claude Code: ~/.claude/"
  fi
  
  printf "\n"
  log_warning "Your personal settings will be preserved."
  printf "\n"
  
  read -p "$(print_color "$BOLD" "Continue with uninstallation? [y/N]: ")" -n 1 -r
  printf "\n"
  
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Uninstallation cancelled."
    exit 0
  fi
}

# Remove AI Rules specific configurations from JSON
remove_ai_rules_config() {
  local file="$1"
  local config_type="$2"
  
  if [ ! -f "$file" ]; then
    return 0
  fi
  
  local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$file" "$backup"
  log_info "Backed up: $backup"
  
  case "$config_type" in
    "settings")
      # Remove AI Rules specific settings while preserving user's
      jq 'del(.env.ENABLE_BACKGROUND_TASKS,
             .env.FORCE_AUTO_BACKGROUND_TASKS,
             .env.CLAUDE_CODE_ENABLE_UNIFIED_READ_TOOL,
             .env.CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR,
             .env.BASH_MAX_TIMEOUT_MS,
             .env.BASH_DEFAULT_TIMEOUT_MS,
             .env.BASH_MAX_OUTPUT_LENGTH,
             .env.CLAUDE_CODE_MAX_OUTPUT_TOKENS,
             .env.MAX_THINKING_TOKENS,
             .env.MCP_TIMEOUT,
             .env.MCP_TOOL_TIMEOUT,
             .env.MAX_MCP_OUTPUT_TOKENS,
             .env.DISABLE_COST_WARNINGS,
             .env.DISABLE_NON_ESSENTIAL_MODEL_CALLS) |
         if .env == {} then del(.env) else . end |
         del(.statusLine) |
         del(.enableAllProjectMcpServers) |
         del(.mcpServers.memory) |
         del(.mcpServers.filesystem) |
         if .mcpServers == {} then del(.mcpServers) else . end' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
      ;;
    
    "hooks")
      # Remove AI Rules specific hooks
      jq 'if .hooks.PostToolUse then
            .hooks.PostToolUse = [.hooks.PostToolUse[] | 
              select(.hooks[0].command | contains("forge fmt") | not) |
              select(.hooks[0].command | contains("prettier") | not)]
          else . end |
          if .hooks.PreToolUse then
            .hooks.PreToolUse = [.hooks.PreToolUse[] |
              select(.hooks[0].command | contains("rm -rf|sudo") | not) |
              select(.hooks[0].command | contains("env|secrets") | not)]
          else . end |
          if .hooks.SessionStart then
            .hooks.SessionStart = [.hooks.SessionStart[] |
              select(.hooks[0].command | contains("Session started at") | not)]
          else . end |
          if .hooks.UserPromptSubmit then
            .hooks.UserPromptSubmit = [.hooks.UserPromptSubmit[] |
              select(.hooks[0].command | contains("password|secret|token") | not)]
          else . end |
          if .hooks.PostToolUse == [] then del(.hooks.PostToolUse) else . end |
          if .hooks.PreToolUse == [] then del(.hooks.PreToolUse) else . end |
          if .hooks.SessionStart == [] then del(.hooks.SessionStart) else . end |
          if .hooks.UserPromptSubmit == [] then del(.hooks.UserPromptSubmit) else . end |
          if .hooks == {} then del(.hooks) else . end' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
      ;;
  esac
  
  # If file is now empty or just {}, remove it
  if [ -f "$file" ]; then
    local content=$(jq -c . "$file" 2>/dev/null || echo "")
    if [ "$content" = "{}" ] || [ "$content" = "[]" ] || [ -z "$content" ]; then
      rm "$file"
      log_info "Removed empty file: $file"
    else
      log_success "Cleaned: $file"
    fi
  fi
}

# Main uninstallation function
main() {
  local dry_run=0
  local force=0
  
  # Parse arguments
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run)
        dry_run=1
        shift
        ;;
      --force)
        force=1
        shift
        ;;
      -h|--help)
        cat <<'USAGE'
Usage: ./uninstall.sh [OPTIONS]

Uninstalls AI Rules configurations from Claude Code.

Options:
  --dry-run        Show what would be removed without making changes
  --force          Skip confirmation prompt
  -h, --help       Show this help message

This uninstaller:
  • Removes AI Rules specific configurations
  • Preserves your personal settings
  • Creates backups before making changes
USAGE
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        exit 2
        ;;
    esac
  done
  
  # Show banner
  show_banner
  
  # Check dependencies
  check_dependencies
  
  # Confirm uninstallation
  if [ "$force" -eq 0 ] && [ "$dry_run" -eq 0 ]; then
    confirm_uninstall
  fi
  
  printf "\n"
  print_color "$BOLD" "Starting uninstallation..."
  printf "\n"
  
  # Uninstall from Claude Code
  print_color "$BOLD" "=== Removing Claude Code Configuration ==="
  
  # Detect OS and set appropriate path
  local claude_code_dir
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows path
    claude_code_dir="$USERPROFILE/.claude"
    log_info "Detected Windows environment"
  else
    # Unix-like path (macOS, Linux)
    claude_code_dir="$HOME/.claude"
  fi
  
  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Target directory: $claude_code_dir"
    printf "\n"
    
    if [ -f "$claude_code_dir/settings.json" ]; then
      # Create temporary files for diff
      local temp_dir=$(mktemp -d)
      local before_file="$temp_dir/before.json"
      local after_file="$temp_dir/after.json"
      
      # Current state
      jq -S '.' "$claude_code_dir/settings.json" > "$before_file" 2>/dev/null || echo '{}' > "$before_file"
      
      # Simulate removal of AI Rules configurations
      jq 'del(.env.ENABLE_BACKGROUND_TASKS,
             .env.FORCE_AUTO_BACKGROUND_TASKS,
             .env.CLAUDE_CODE_ENABLE_UNIFIED_READ_TOOL,
             .env.CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR,
             .env.BASH_MAX_TIMEOUT_MS,
             .env.BASH_DEFAULT_TIMEOUT_MS,
             .env.BASH_MAX_OUTPUT_LENGTH,
             .env.CLAUDE_CODE_MAX_OUTPUT_TOKENS,
             .env.MAX_THINKING_TOKENS,
             .env.MCP_TIMEOUT,
             .env.MCP_TOOL_TIMEOUT,
             .env.MAX_MCP_OUTPUT_TOKENS,
             .env.DISABLE_COST_WARNINGS,
             .env.DISABLE_NON_ESSENTIAL_MODEL_CALLS) |
         if .env == {} then del(.env) else . end |
         del(.statusLine) |
         del(.enableAllProjectMcpServers) |
         del(.mcpServers.memory) |
         del(.mcpServers.filesystem) |
         if .mcpServers == {} then del(.mcpServers) else . end |
         if .hooks.PostToolUse then
           .hooks.PostToolUse = [.hooks.PostToolUse[] | 
             select(.hooks[0].command | contains("forge fmt") | not) |
             select(.hooks[0].command | contains("prettier") | not)]
         else . end |
         if .hooks.PreToolUse then
           .hooks.PreToolUse = [.hooks.PreToolUse[] |
             select(.hooks[0].command | contains("rm -rf|sudo") | not) |
             select(.hooks[0].command | contains("env|secrets") | not)]
         else . end |
         if .hooks.SessionStart then
           .hooks.SessionStart = [.hooks.SessionStart[] |
             select(.hooks[0].command | contains("Session started at") | not)]
         else . end |
         if .hooks.UserPromptSubmit then
           .hooks.UserPromptSubmit = [.hooks.UserPromptSubmit[] |
             select(.hooks[0].command | contains("password|secret|token") | not)]
         else . end |
         if .hooks.PostToolUse == [] then del(.hooks.PostToolUse) else . end |
         if .hooks.PreToolUse == [] then del(.hooks.PreToolUse) else . end |
         if .hooks.SessionStart == [] then del(.hooks.SessionStart) else . end |
         if .hooks.UserPromptSubmit == [] then del(.hooks.UserPromptSubmit) else . end |
         if .hooks == {} then del(.hooks) else . end' "$before_file" | jq -S '.' > "$after_file"
      
      # Show the diff
      print_color "$BOLD" "📝 Changes that would be made to settings.json:"
      printf "\n"
      
      # Prefer delta for beautiful diffs, fall back to diff
      if command -v delta >/dev/null 2>&1; then
        # Use delta with compact options for better readability
        diff -u --label "current" --label "after removal" "$before_file" "$after_file" 2>/dev/null | \
          delta --no-gitconfig \
                --paging=never \
                --line-numbers \
                --syntax-theme="Dracula" \
                --width="${COLUMNS:-120}" \
                --wrap-max-lines=2 \
                --max-line-length=512 \
                --diff-so-fancy \
                --hyperlinks 2>/dev/null || true
      elif command -v diff >/dev/null 2>&1; then
        # Fall back to regular diff with manual coloring
        # Try to use colored diff
        if diff --color=auto "$before_file" "$after_file" >/dev/null 2>&1; then
          diff --color=auto -u --label "current" --label "after removal" "$before_file" "$after_file" | tail -n +4
        else
          # Fall back to plain diff with manual coloring
          diff -u --label "current" --label "after removal" "$before_file" "$after_file" | tail -n +4 | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "$line" ;;
              -*) print_color "$RED" "$line" ;;
              @*) print_color "$CYAN" "$line" ;;
              *) echo "$line" ;;
            esac
          done
        fi
      else
        log_warning "Neither delta nor diff command available"
        print_color "$YELLOW" "AI Rules configurations would be removed from settings.json"
      fi
      
      # Clean up temp files
      rm -rf "$temp_dir"
    else
      log_warning "No settings.json file found"
    fi
    
    # Show agents that would be removed
    if [ -d "$claude_code_dir/agents" ]; then
      printf "\n"
      print_color "$BOLD" "🤖 Agents that would be removed:"
      if [ -f "$claude_code_dir/agents/code-reviewer.md" ]; then
        print_color "$RED" "  - code-reviewer"
      fi
    fi
    
    # Show commands that would be removed
    if [ -d "$claude_code_dir/commands" ]; then
      printf "\n"
      print_color "$BOLD" "📋 Commands that would be removed:"
      if [ -f "$claude_code_dir/commands/review.md" ]; then
        print_color "$RED" "  - /review"
      fi
    fi
    
    # Show CLAUDE.md that would be removed
    if [ -f "$claude_code_dir/CLAUDE.md" ]; then
      printf "\n"
      print_color "$BOLD" "📄 CLAUDE.md file that would be removed:"
      print_color "$RED" "  - CLAUDE.md"
    fi
    
    if [ -f "$claude_code_dir/.ai-rules-manifest.json" ]; then
      print_color "$RED" "\n  • AI Rules manifest file would be removed"
    fi
    printf "\n"
  else
    # Process settings.json (remove AI Rules configs, preserve user's)
    if [ -f "$claude_code_dir/settings.json" ]; then
      remove_ai_rules_config "$claude_code_dir/settings.json" "settings"
      remove_ai_rules_config "$claude_code_dir/settings.json" "hooks"
    fi
    
    # Remove agents installed by AI Rules
    if [ -d "$claude_code_dir/agents" ]; then
      # Only remove agents that we installed (code-reviewer.md)
      if [ -f "$claude_code_dir/agents/code-reviewer.md" ]; then
        rm "$claude_code_dir/agents/code-reviewer.md"
        log_success "Removed agent: code-reviewer.md"
      fi
      # Remove directory if empty
      rmdir "$claude_code_dir/agents" 2>/dev/null || true
    fi
    
    # Remove commands installed by AI Rules
    if [ -d "$claude_code_dir/commands" ]; then
      # Only remove commands that we installed (review.md)
      if [ -f "$claude_code_dir/commands/review.md" ]; then
        rm "$claude_code_dir/commands/review.md"
        log_success "Removed command: review.md"
      fi
      # Remove directory if empty
      rmdir "$claude_code_dir/commands" 2>/dev/null || true
    fi
    
    # Remove CLAUDE.md installed by AI Rules
    if [ -f "$claude_code_dir/CLAUDE.md" ]; then
      rm "$claude_code_dir/CLAUDE.md"
      log_success "Removed CLAUDE.md"
    fi
    
    # Remove manifest
    if [ -f "$claude_code_dir/.ai-rules-manifest.json" ]; then
      rm "$claude_code_dir/.ai-rules-manifest.json"
      log_success "Removed manifest"
    fi
  fi
  printf "\n"
  
  # Success message
  print_color "$BOLD$GREEN" "    ╔════════════════════════════════════════╗"
  print_color "$BOLD$GREEN" "    ║     Uninstallation Complete! ${SUCCESS}       ║"
  print_color "$BOLD$GREEN" "    ╚════════════════════════════════════════╝"
  printf "\n"
  
  log_success "AI Rules has been successfully removed!"
  log_info "Your personal settings have been preserved."
  printf "\n"
  
  # Reinstallation instructions
  print_color "$CYAN" "To reinstall AI Rules, run:"
  print_color "$YELLOW" "  ./install.sh"
  printf "\n"
  
  # Show backup locations
  print_color "$CYAN" "Backup files created during uninstallation:"
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    print_color "$YELLOW" "  Look for *.backup.* files in: %USERPROFILE%\\.claude\\"
  else
    print_color "$YELLOW" "  Look for *.backup.* files in: ~/.claude/"
  fi
  printf "\n"
}

# Run main function
main "$@"