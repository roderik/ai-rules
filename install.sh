#!/usr/bin/env bash

set -euo pipefail

# AI Rules installer for Claude Code and Claude Desktop
# Merges settings, hooks, and MCP configurations into existing files

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
ROCKET="🚀"

# Path validation function to prevent directory traversal and injection attacks
validate_path() {
  local path="$1"
  local description="${2:-path}"

  # Check for directory traversal attempts
  if [[ "$path" == *".."* ]]; then
    printf "${RED}${ERROR} Invalid %s: Path cannot contain '..' (directory traversal)${NC}\n" "$description" >&2
    return 1
  fi

  # Check for absolute paths
  if [[ "$path" == "/"* ]]; then
    printf "${RED}${ERROR} Invalid %s: Path cannot be absolute${NC}\n" "$description" >&2
    return 1
  fi

  # Check for path starting with tilde (home directory expansion)
  if [[ "$path" == "~"* ]]; then
    printf "${RED}${ERROR} Invalid %s: Path cannot start with '~'${NC}\n" "$description" >&2
    return 1
  fi


  # Check for command injection characters in filenames
  # These characters pose significant security risks in shell contexts
  # shellcheck disable=SC2016
  if [[ "$path" == *";"* ]] || [[ "$path" == *"|"* ]] || [[ "$path" == *"&"* ]] || \
     [[ "$path" == *'`'* ]] || [[ "$path" == *'$('* ]] || [[ "$path" == *">"* ]] || \
     [[ "$path" == *"<"* ]]; then
    printf '%s%s Invalid %s: Path contains potentially dangerous characters%s\n' "$RED" "$ERROR" "$description" "$NC" >&2
    return 1
  fi

  return 0
}

# Print colored output
print_color() {
  local color=$1
  shift
  printf '%s%s%s\n' "$color" "$*" "$NC"
}

# Print status messages
log_success() { printf '%s%s %s%s\n' "$GREEN" "$SUCCESS" "$*" "$NC"; }
log_error() { printf '%s%s %s%s\n' "$RED" "$ERROR" "$*" "$NC" >&2; }
log_warning() { printf '%s%s %s%s\n' "$YELLOW" "$WARNING" "$*" "$NC"; }
log_info() { printf '%s%s %s%s\n' "$CYAN" "$INFO" "$*" "$NC"; }

# Display ASCII art with gradient colors
show_banner() {
  printf "\n"
  printf '%s\n' "${BLUE}     █████${CYAN}╗ ██${GREEN}╗    ██████${YELLOW}╗ ██${MAGENTA}╗   ██${RED}╗██${BLUE}╗     ███████${CYAN}╗███████${GREEN}╗${NC}"
  printf '%s\n' "${BLUE}    ██${CYAN}╔══██╗██${GREEN}║    ██${YELLOW}╔══██╗██${MAGENTA}║   ██${RED}║██${BLUE}║     ██${CYAN}╔════╝██${GREEN}╔════╝${NC}"
  printf '%s\n' "${BLUE}    ███████${CYAN}║██${GREEN}║    ██████${YELLOW}╔╝██${MAGENTA}║   ██${RED}║██${BLUE}║     █████${CYAN}╗  ███████${GREEN}╗${NC}"
  printf '%s\n' "${BLUE}    ██${CYAN}╔══██║██${GREEN}║    ██${YELLOW}╔══██╗██${MAGENTA}║   ██${RED}║██${BLUE}║     ██${CYAN}╔══╝  ╚════██${GREEN}║${NC}"
  printf '%s\n' "${BLUE}    ██${CYAN}║  ██║██${GREEN}║    ██${YELLOW}║  ██║╚██████${MAGENTA}╔╝███████${RED}╗███████${BLUE}╗███████${CYAN}║${NC}"
  printf '%s\n' "${BLUE}    ╚═${CYAN}╝  ╚═╝╚═${GREEN}╝    ╚═${YELLOW}╝  ╚═╝ ╚═════${MAGENTA}╝ ╚══════${RED}╝╚══════${BLUE}╝╚══════${CYAN}╝${NC}"
  printf "\n"
  printf '%s\n' "${BOLD}${MAGENTA}╔═══════════════════════════╗${NC}"
  printf '%s\n' "${BOLD}${CYAN}║      AI Rules Setup       ║${NC}"
  printf '%s\n' "${BOLD}${MAGENTA}╚═══════════════════════════╝${NC}"
  printf "\n"
}

# Check for required dependencies
check_dependencies() {
  local missing_deps=()

  for cmd in jq git; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing_deps+=("$cmd")
    fi
  done

  if [ ${#missing_deps[@]} -gt 0 ]; then
    log_error "Missing required dependencies: ${missing_deps[*]}"
    log_info "Please install the missing tools and try again."

    # Provide installation hints
    if [[ "$OSTYPE" == "darwin"* ]]; then
      log_info "On macOS, you can install with: brew install ${missing_deps[*]}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      log_info "On Linux, install with your package manager (apt, yum, etc.)"
    fi
    exit 1
  fi
}

# Detect the script directory
script_dir() {
  local src="$0"
  while [ -h "$src" ]; do
    local dir
    dir=$(cd -P "$(dirname "$src")" && pwd)
    src=$(readlink "$src")
    case $src in
      /*) ;;
      *) src="$dir/$src" ;;
    esac
  done
  cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd
}

# Merge JSON files using jq
merge_json() {
  local target="$1"
  local source="$2"
  local backup
  backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"

  # Create target directory if needed
  mkdir -p "$(dirname "$target")"

  # Backup existing file if it exists
  if [ -f "$target" ]; then
    cp "$target" "$backup"
    log_info "Backed up existing file to: $backup"
  fi

  # Merge or create
  if [ -f "$target" ]; then
    # Merge existing with new, but fully override MCP-related configs
    jq -s '
      .[0] as $old | .[1] as $new |
      ($old * $new)
      | (if ($new | has("mcpServers")) then .mcpServers = $new.mcpServers else . end)
      | (if ($new | has("mcp"))        then .mcp        = $new.mcp        else . end)
      | (if ($new | has("enableAllProjectMcpServers"))
           then .enableAllProjectMcpServers = $new.enableAllProjectMcpServers else . end)
    ' "$target" "$source" > "${target}.tmp" && mv "${target}.tmp" "$target"
    log_success "Updated (MCP overridden) into: $target"
  else
    # Copy new file
    cp "$source" "$target"
    log_success "Created: $target"
  fi
}

# Merge hooks specifically (append to arrays)
merge_hooks() {
  local target="$1"
  local source="$2"
  local backup
  backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"

  mkdir -p "$(dirname "$target")"

  if [ -f "$target" ]; then
    cp "$target" "$backup"
    log_info "Backed up existing hooks to: $backup"

    # Merge hooks using Python for better error handling
    python3 -c "
import json
import sys

# Read existing settings
with open('$target', 'r') as f:
    settings = json.load(f)

# Read new hooks
with open('$source', 'r') as f:
    new_hooks_data = json.load(f)
    new_hooks = new_hooks_data.get('hooks', {})

# Initialize hooks if not present
if 'hooks' not in settings:
    settings['hooks'] = {}

# Merge hooks - combine arrays, replace other types
for hook_type, hook_value in new_hooks.items():
    if hook_type in settings['hooks']:
        existing = settings['hooks'][hook_type]
        if isinstance(existing, list) and isinstance(hook_value, list):
            # Combine arrays and remove duplicates
            combined = existing + hook_value
            # Remove duplicates while preserving order
            seen = set()
            unique = []
            for item in combined:
                item_str = json.dumps(item, sort_keys=True)
                if item_str not in seen:
                    seen.add(item_str)
                    unique.append(item)
            settings['hooks'][hook_type] = unique
        else:
            # Replace with new value
            settings['hooks'][hook_type] = hook_value
    else:
        # Add new hook type
        settings['hooks'][hook_type] = hook_value

# Write merged settings
with open('${target}.tmp', 'w') as f:
    json.dump(settings, f, indent=2)
" && mv "${target}.tmp" "$target"

    log_success "Merged hooks into: $target"
  else
    cp "$source" "$target"
    log_success "Created: $target"
  fi
}

# Main installation function
main() {
  # Force overwrite flag is handled through user prompts
  local dry_run=0

  # Parse arguments
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --force)
        # Force overwrite flag (handled via prompts)
        shift
        ;;
      --dry-run)
        dry_run=1
        shift
        ;;
      -h|--help)
        cat <<'USAGE'
Usage: ./install.sh [OPTIONS]

Installs AI Rules configurations for Claude Code.

Options:
  --force          Overwrite existing configurations
  --dry-run        Show what would be done without making changes
  -h, --help       Show this help message

Configuration is installed to: ~/.claude/
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

  # Detect source directory
  local repo_root
  repo_root=$(script_dir)
  local src_base="$repo_root/.claude"
  local codex_base="$repo_root/.codex"
  local gemini_base="$repo_root/.gemini"
  local opencode_base="$repo_root/.opencode"

  # Check if we're running from a piped/curl execution (no .claude directory)
  if [ ! -d "$src_base" ]; then
    log_info "Remote installation detected. Cloning ai-rules repository..."

    # Create temporary directory for the repository
    local temp_repo="/tmp/ai-rules-install-$$"

    # Clone the repository
    if ! git clone --quiet https://github.com/roderik/ai-rules.git "$temp_repo" 2>/dev/null; then
      log_error "Failed to clone ai-rules repository"
      log_info "Please check your internet connection and try again."
      exit 1
    fi

    # Update paths to use the cloned repository
    repo_root="$temp_repo"
    src_base="$repo_root/.claude"
    codex_base="$repo_root/.codex"
    gemini_base="$repo_root/.gemini"
    opencode_base="$repo_root/.opencode"

    # Verify the cloned repository has the expected structure
    if [ ! -d "$src_base" ]; then
      log_error "Invalid repository structure: .claude directory not found"
      rm -rf "$temp_repo"
      exit 1
    fi

    log_success "Repository cloned successfully"

    # Set a flag to clean up the temp directory on exit
    trap 'rm -rf "'"$temp_repo"'"' EXIT
  fi

  log_info "Installing from: $src_base"
  printf "\n"

  # Install Claude Code configuration
  print_color "$BOLD" "=== Installing Claude Code Configuration ==="

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

    # Create temporary files for diff
    local temp_dir
    temp_dir=$(mktemp -d)
    local before_file="$temp_dir/before.json"
    local after_file="$temp_dir/after.json"

    # Prepare the "before" state
    if [ -f "$HOME/.claude.json" ]; then
      jq -S '.' "$HOME/.claude.json" > "$before_file" 2>/dev/null || echo '{}' > "$before_file"
    else
      echo '{}' > "$before_file"
    fi

    # Prepare the "after" state by simulating the merge
    local merged_content
    merged_content=$(cat "$before_file")

    # Merge settings but override MCP-related configs entirely
    if [ -f "$src_base/settings.json" ]; then
      merged_content=$(echo "$merged_content" | jq -s --slurpfile new "$src_base/settings.json" '
        .[0] as $old | $new[0] as $new |
        ($old * $new)
        | (if ($new | has("mcpServers")) then .mcpServers = $new.mcpServers else . end)
        | (if ($new | has("mcp"))        then .mcp        = $new.mcp        else . end)
        | (if ($new | has("enableAllProjectMcpServers"))
             then .enableAllProjectMcpServers = $new.enableAllProjectMcpServers else . end)
      ')
    fi

    # Note: hooks and MCP servers are now part of settings.json
    # No separate merging needed as they're handled in the settings merge above

    # Write the merged content to after file
    echo "$merged_content" | jq -S '.' > "$after_file"

    # Show the diff for ~/.claude.json
    print_color "$BOLD" "📝 Changes that would be made to ~/.claude.json:"
    printf "\n"

    if [ -f "$HOME/.claude.json" ]; then
      # Prefer delta for beautiful diffs, fall back to diff
      if command -v delta >/dev/null 2>&1; then
        # Use delta with compact options for better readability
        # --width: Use terminal width or max 120 chars
        # --wrap-max-lines: Wrap long lines instead of truncating
        # --max-line-length: Prevent extremely long lines
        diff -u --label "current" --label "after merge" "$before_file" "$after_file" 2>/dev/null | \
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
        diff -u --label "current" --label "after merge" "$before_file" "$after_file" 2>/dev/null | tail -n +4 | while IFS= read -r line; do
          case "$line" in
            +*) print_color "$GREEN" "$line" ;;
            -*) print_color "$RED" "$line" ;;
            @*) print_color "$CYAN" "$line" ;;
            *) echo "$line" ;;
          esac
        done
      else
        log_warning "Neither delta nor diff command available, showing JSON comparison"
        print_color "$YELLOW" "New configuration that would be merged:"
        jq -S '.' "$after_file"
      fi
    else
      print_color "$YELLOW" "  New file would be created with AI Rules configuration"
      print_color "$GREEN" "  Content preview:"
      jq -C '.' "$after_file" 2>/dev/null || jq '.' "$after_file"
    fi

    # Show agents that would be installed with diff
    printf "\n"
    print_color "$BOLD" "🤖 Agents that would be installed to ~/.claude/agents/:"
    printf "\n"
    if [ -d "$src_base/agents" ]; then
      find "$src_base/agents" -name "*.md" -type f | while read -r agent_file; do
        local agent_name
        agent_name=$(basename "$agent_file" .md)
        if ! validate_path "$agent_name.md" "agent filename"; then
          log_error "Skipping invalid agent filename: $agent_name"
          continue
        fi
        local target_file="$claude_code_dir/agents/${agent_name}.md"
        # Just copy the agent file directly (no shared content)
        local temp_file="/tmp/agent_preview_${agent_name}_$$.md"
        cp "$agent_file" "$temp_file"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  $agent_name.md (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            # Use delta with compact display
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + $agent_name.md (new file with shared content)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$temp_file" | sed 's/^/      /'
        fi

        rm -f "$temp_file"
      done
    fi

    # Show commands that would be installed with diff
    printf "\n"
    print_color "$BOLD" "📋 Commands that would be installed to ~/.claude/commands/:"
    printf "\n"
    if [ -d "$src_base/commands" ]; then
      find "$src_base/commands" -name "*.md" -type f | while read -r cmd_file; do
        local cmd_name
        cmd_name=$(basename "$cmd_file" .md)
        if ! validate_path "$cmd_name.md" "command filename"; then
          log_error "Skipping invalid command filename: $cmd_name"
          continue
        fi
        local target_file="$claude_code_dir/commands/${cmd_name}.md"
        # Just copy the command file directly (no shared content)
        local temp_file="/tmp/command_preview_${cmd_name}_$$.md"
        cp "$cmd_file" "$temp_file"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  /${cmd_name}.md (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            # Use delta with compact display
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + /${cmd_name}.md (new file with shared content)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$temp_file" | sed 's/^/      /'
        fi

        rm -f "$temp_file"
      done
    fi

    # Show CLAUDE.md that would be installed
    printf "\n"
    print_color "$BOLD" "📄 CLAUDE.md file that would be installed to ~/.claude/:"
    printf "\n"
    if [ -f "$repo_root/CLAUDE.md" ]; then
      local target_file="$claude_code_dir/CLAUDE.md"
      if [ -f "$target_file" ]; then
        # Show diff if file exists
        print_color "$YELLOW" "  ⚠️  CLAUDE.md (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/CLAUDE.md" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/CLAUDE.md" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + CLAUDE.md (new file)"
        print_color "$CYAN" "    Preview (first 10 lines):"
        head -10 "$repo_root/CLAUDE.md" | sed 's/^/      /'
      fi
    fi

    # Clean up temp files
    rm -rf "$temp_dir"
    printf "\n"
  else
    # Merge settings.json into ~/.claude.json (includes hooks and MCP servers)
    if [ -f "$src_base/settings.json" ]; then
      merge_json "$HOME/.claude.json" "$src_base/settings.json"
    fi

    # Install agents (overwrite markdown as-is, no shared content, no backups)
    if [ -d "$src_base/agents" ]; then
      printf "\n"
      print_color "$BOLD" "Installing AI Agents..."
      mkdir -p "$claude_code_dir/agents"

      # Process each agent
      find "$src_base/agents" -name "*.md" -type f | while read -r agent_file; do
        local agent_name
        agent_name=$(basename "$agent_file" .md)
        if ! validate_path "$agent_name.md" "agent filename"; then
          log_error "Skipping invalid agent filename: $agent_name"
          continue
        fi
        local target_file="$claude_code_dir/agents/${agent_name}.md"
        # Just copy the agent file directly (no shared content)
        local temp_file="/tmp/agent_${agent_name}_$$.md"
        cp "$agent_file" "$temp_file"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  $agent_name.md (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + $agent_name.md (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$temp_file" | sed 's/^/      /'
        fi

        log_info "Installing agent: $agent_name to ~/.claude/agents/"
        mv "$temp_file" "$target_file"
        log_success "Installed agent: $agent_name.md"
      done
    fi

    # Install commands (overwrite markdown as-is, no shared content, no backups)
    if [ -d "$src_base/commands" ]; then
      printf "\n"
      print_color "$BOLD" "Installing Custom Commands..."
      mkdir -p "$claude_code_dir/commands"
      find "$src_base/commands" -name "*.md" -type f | while read -r cmd_file; do
        local cmd_name
        cmd_name=$(basename "$cmd_file" .md)
        if ! validate_path "$cmd_name.md" "command filename"; then
          log_error "Skipping invalid command filename: $cmd_name"
          continue
        fi
        local target_file="$claude_code_dir/commands/${cmd_name}.md"
        # Just copy the command file directly (no shared content)
        local temp_file="/tmp/command_${cmd_name}_$$.md"
        cp "$cmd_file" "$temp_file"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  /${cmd_name}.md (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + /${cmd_name}.md (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$temp_file" | sed 's/^/      /'
        fi

        log_info "Installing command: $cmd_name to ~/.claude/commands/"
        mv "$temp_file" "$target_file"
        log_success "Installed command: /${cmd_name}.md"
      done
    fi

    # Install CLAUDE.md file to global user folder
    if [ -f "$repo_root/CLAUDE.md" ]; then
      printf "\n"
      print_color "$BOLD" "Installing CLAUDE.md..."
      local target_file="$claude_code_dir/CLAUDE.md"

      if [ -f "$target_file" ]; then
        # Show diff if file exists
        print_color "$YELLOW" "  ⚠️  CLAUDE.md (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/CLAUDE.md" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/CLAUDE.md" 2>/dev/null | head -20 | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + CLAUDE.md (new file)"
        print_color "$CYAN" "    Preview (first 10 lines):"
        head -10 "$repo_root/CLAUDE.md" | sed 's/^/      /'
      fi

      cp "$repo_root/CLAUDE.md" "$target_file"
      log_success "Installed CLAUDE.md to ~/.claude/"
    fi

    # Note: output-styles are no longer part of the installation

    # Create manifest for uninstall
    local manifest="$claude_code_dir/.ai-rules-manifest.json"
    cat > "$manifest" <<EOF
{
  "version": "1.0",
  "installed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "source": "$repo_root",
  "configurations": [
    "settings.json",
    "agents/",
    "commands/",
    "CLAUDE.md"
  ]
}
EOF
    log_success "Created manifest: $manifest"
  fi
  printf "\n"

  # Install Codex CLI configuration
  print_color "$BOLD" "=== Installing Codex CLI Configuration ==="

  # Detect OS and set appropriate path for Codex
  local codex_dir
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows path
    codex_dir="$USERPROFILE/.codex"
    log_info "Detected Windows environment for Codex"
  else
    # Unix-like path (macOS, Linux)
    codex_dir="$HOME/.codex"
  fi

  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would install Codex configuration to: $codex_dir"

    # Show config.toml that would be installed
    printf "\n"
    print_color "$BOLD" "⚙️  config.toml that would be installed to ~/.codex/:"
    printf "\n"
    if [ -f "$codex_base/config.toml" ]; then
      local target_file="$codex_dir/config.toml"
      if [ -f "$target_file" ]; then
        # Show diff if file exists
        print_color "$YELLOW" "  ⚠️  config.toml (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$codex_base/config.toml" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$codex_base/config.toml" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + config.toml (new file)"
        print_color "$CYAN" "    Preview (first 20 lines):"
        head -20 "$codex_base/config.toml" | sed 's/^/      /'
      fi
    fi

    # Show AGENTS.md that would be installed
    printf "\n"
    print_color "$BOLD" "📄 AGENTS.md file that would be installed to ~/.codex/:"
    printf "\n"
    if [ -f "$repo_root/AGENTS.md" ]; then
      local target_file="$codex_dir/AGENTS.md"
      if [ -f "$target_file" ]; then
        # Show diff if file exists
        print_color "$YELLOW" "  ⚠️  AGENTS.md (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + AGENTS.md (new file)"
        print_color "$CYAN" "    Preview (first 10 lines):"
        head -10 "$repo_root/AGENTS.md" | sed 's/^/      /'
      fi
    fi

    # Show prompts that would be installed to ~/.codex/prompts/
    printf "\n"
    print_color "$BOLD" "🧠 Prompt files that would be installed to ~/.codex/prompts/:"
    printf "\n"
    if [ -d "$codex_base/prompts" ]; then
      for prompt in "$codex_base"/prompts/*.md; do
        [ -e "$prompt" ] || continue
        local prompt_name
        prompt_name="$(basename "$prompt")"
        local target_prompt="$codex_dir/prompts/$prompt_name"
        if [ -f "$target_prompt" ]; then
          print_color "$YELLOW" "  ⚠️  $prompt_name (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_prompt" "$prompt" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_prompt" "$prompt" 2>/dev/null | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          print_color "$GREEN" "  + $prompt_name (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$prompt" | sed 's/^/      /'
        fi
      done
    else
      print_color "$YELLOW" "  ⚠️  No prompt files found in repository .codex/prompts/"
    fi
  else
    # Install Codex config.toml
    if [ -f "$codex_base/config.toml" ]; then
      mkdir -p "$codex_dir"
      local backup
      backup="${codex_dir}/config.toml.backup.$(date +%Y%m%d_%H%M%S)"
      local target_file="$codex_dir/config.toml"

      # Backup existing file if it exists
      if [ -f "$target_file" ]; then
        cp "$target_file" "$backup"
        log_info "Backed up existing Codex config to: $backup"

        # Show diff
        print_color "$YELLOW" "  ⚠️  config.toml (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$codex_base/config.toml" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$codex_base/config.toml" 2>/dev/null | head -20 | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + config.toml (new file)"
        print_color "$CYAN" "    Preview (first 20 lines):"
        head -20 "$codex_base/config.toml" | sed 's/^/      /'
      fi

      cp "$codex_base/config.toml" "$target_file"
      log_success "Installed config.toml to ~/.codex/"
    fi

    # Install AGENTS.md
    if [ -f "$repo_root/AGENTS.md" ]; then
      local backup
      backup="${codex_dir}/AGENTS.md.backup.$(date +%Y%m%d_%H%M%S)"
      local target_file="$codex_dir/AGENTS.md"

      # Backup existing file if it exists
      if [ -f "$target_file" ]; then
        cp "$target_file" "$backup"
        log_info "Backed up existing AGENTS.md to: $backup"

        # Show diff
        print_color "$YELLOW" "  ⚠️  AGENTS.md (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | head -20 | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + AGENTS.md (new file)"
        print_color "$CYAN" "    Preview (first 10 lines):"
        head -10 "$repo_root/AGENTS.md" | sed 's/^/      /'
      fi

      cp "$repo_root/AGENTS.md" "$target_file"
      log_success "Installed AGENTS.md to ~/.codex/"
    fi

    # Install Codex prompt files
    if [ -d "$codex_base/prompts" ]; then
      mkdir -p "$codex_dir/prompts"
      for prompt in "$codex_base"/prompts/*.md; do
        [ -e "$prompt" ] || continue
        local prompt_name
        prompt_name="$(basename "$prompt")"
        local target_prompt="$codex_dir/prompts/$prompt_name"
        if [ -f "$target_prompt" ]; then
          local backup
          backup="${target_prompt}.backup.$(date +%Y%m%d_%H%M%S)"
          cp "$target_prompt" "$backup"
          log_info "Backed up existing prompt $prompt_name to: $backup"
          print_color "$YELLOW" "  ⚠️  $prompt_name (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_prompt" "$prompt" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_prompt" "$prompt" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          print_color "$GREEN" "  + $prompt_name (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$prompt" | sed 's/^/      /'
        fi
        cp "$prompt" "$target_prompt"
        log_success "Installed prompt $prompt_name to ~/.codex/prompts/"
      done
    fi

    # Update manifest to include Codex files
    local manifest="$claude_code_dir/.ai-rules-manifest.json"
    cat > "$manifest" <<EOF
{
  "version": "1.0",
  "installed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "source": "$repo_root",
  "configurations": [
    "settings.json",
    "agents/",
    "commands/",
    "CLAUDE.md"
  ],
  "codex_configurations": [
    "$codex_dir/config.toml",
    "$codex_dir/AGENTS.md",
    "$codex_dir/prompts/"
  ]
}
EOF
    log_success "Updated manifest: $manifest"
  fi

  printf "\n"

  # Install Gemini CLI configuration
  print_color "$BOLD" "=== Installing Gemini CLI Configuration ==="

  # Detect OS and set appropriate path for Gemini
  local gemini_dir
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows path
    gemini_dir="$USERPROFILE/.gemini"
    log_info "Detected Windows environment for Gemini"
  else
    # Unix-like path (macOS, Linux)
    gemini_dir="$HOME/.gemini"
  fi

  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would install Gemini configuration to: $gemini_dir"

    # Show AGENTS.md that would be installed
    printf "\n"
    print_color "$BOLD" "📄 AGENTS.md file that would be installed to ~/.gemini/:"
    printf "\n"
    if [ -f "$repo_root/AGENTS.md" ]; then
      local target_file="$gemini_dir/AGENTS.md"
      if [ -f "$target_file" ]; then
        # Show diff if file exists
        print_color "$YELLOW" "  ⚠️  AGENTS.md (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + AGENTS.md (new file)"
        print_color "$CYAN" "    Preview (first 10 lines):"
        head -10 "$repo_root/AGENTS.md" | sed 's/^/      /'
      fi
    fi

    # Show settings.json that would be installed
    printf "\n"
    print_color "$BOLD" "⚙️  settings.json that would be installed to ~/.gemini/:"
    printf "\n"
    if [ -f "$gemini_base/settings.json" ]; then
      local target_file="$gemini_dir/settings.json"
      if [ -f "$target_file" ]; then
        # Show diff if file exists
        print_color "$YELLOW" "  ⚠️  settings.json (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$gemini_base/settings.json" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$gemini_base/settings.json" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + settings.json (new file)"
        print_color "$CYAN" "    Preview (first 20 lines):"
        head -20 "$gemini_base/settings.json" | sed 's/^/      /'
      fi
    fi

    # Show commands.toml that would be installed
    printf "\n"
    print_color "$BOLD" "📋 commands.toml that would be installed to ~/.gemini/:"
    printf "\n"
    if [ -f "$gemini_base/commands.toml" ]; then
      local target_file="$gemini_dir/commands.toml"
      if [ -f "$target_file" ]; then
        # Show diff if file exists
        print_color "$YELLOW" "  ⚠️  commands.toml (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$gemini_base/commands.toml" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$gemini_base/commands.toml" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + commands.toml (new file)"
        print_color "$CYAN" "    Preview (first 15 lines):"
        head -15 "$gemini_base/commands.toml" | sed 's/^/      /'
      fi
    fi
  else
    # Install Gemini configuration files
    if [ -d "$gemini_base" ]; then
      mkdir -p "$gemini_dir"

      # Install AGENTS.md from root
      if [ -f "$repo_root/AGENTS.md" ]; then
        local backup
        backup="${gemini_dir}/AGENTS.md.backup.$(date +%Y%m%d_%H%M%S)"
        local target_file="$gemini_dir/AGENTS.md"

        # Backup existing file if it exists
        if [ -f "$target_file" ]; then
          cp "$target_file" "$backup"
          log_info "Backed up existing AGENTS.md to: $backup"

          # Show diff
          print_color "$YELLOW" "  ⚠️  AGENTS.md (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + AGENTS.md (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$repo_root/AGENTS.md" | sed 's/^/      /'
        fi

        cp "$repo_root/AGENTS.md" "$target_file"
        log_success "Installed AGENTS.md to ~/.gemini/"
      fi

      # Install settings.json
      if [ -f "$gemini_base/settings.json" ]; then
        local backup
        backup="${gemini_dir}/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        local target_file="$gemini_dir/settings.json"

        # Backup existing file if it exists
        if [ -f "$target_file" ]; then
          cp "$target_file" "$backup"
          log_info "Backed up existing Gemini settings to: $backup"

          # Show diff
          print_color "$YELLOW" "  ⚠️  settings.json (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$gemini_base/settings.json" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$gemini_base/settings.json" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + settings.json (new file)"
          print_color "$CYAN" "    Preview (first 20 lines):"
          head -20 "$gemini_base/settings.json" | sed 's/^/      /'
        fi

        cp "$gemini_base/settings.json" "$target_file"
        log_success "Installed settings.json to ~/.gemini/"
      fi

      # Install commands.toml
      if [ -f "$gemini_base/commands.toml" ]; then
        local backup
        backup="${gemini_dir}/commands.toml.backup.$(date +%Y%m%d_%H%M%S)"
        local target_file="$gemini_dir/commands.toml"

        # Backup existing file if it exists
        if [ -f "$target_file" ]; then
          cp "$target_file" "$backup"
          log_info "Backed up existing commands.toml to: $backup"

          # Show diff
          print_color "$YELLOW" "  ⚠️  commands.toml (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$gemini_base/commands.toml" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$gemini_base/commands.toml" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + commands.toml (new file)"
          print_color "$CYAN" "    Preview (first 15 lines):"
          head -15 "$gemini_base/commands.toml" | sed 's/^/      /'
        fi

        cp "$gemini_base/commands.toml" "$target_file"
        log_success "Installed commands.toml to ~/.gemini/"
      fi

      # Update manifest to include Gemini files
      local manifest="$claude_code_dir/.ai-rules-manifest.json"
      cat > "$manifest" <<EOF
{
  "version": "1.0",
  "installed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "source": "$repo_root",
  "configurations": [
    "settings.json",
    "agents/",
    "commands/",
    "CLAUDE.md"
  ],
  "codex_configurations": [
    "$codex_dir/config.toml",
    "$codex_dir/AGENTS.md"
  ],
  "gemini_configurations": [
    "$gemini_dir/AGENTS.md",
    "$gemini_dir/settings.json",
    "$gemini_dir/commands.toml"
  ]
}
EOF
      log_success "Updated manifest: $manifest"
    fi
  fi

  printf "\n"

  # Install OpenCode configuration
  print_color "$BOLD" "=== Installing OpenCode Configuration ==="

  # Detect OS and set appropriate path for OpenCode
  local opencode_dir
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows path
    opencode_dir="$USERPROFILE/.config/opencode"
    log_info "Detected Windows environment for OpenCode"
    rm -rf $USERPROFILE/.cache/opencode
  else
    # Unix-like path (macOS, Linux)
    opencode_dir="$HOME/.config/opencode"
    rm -rf $HOME/.cache/opencode
  fi


  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would install OpenCode agents to: $opencode_dir/agent/"

    # Show agents that would be installed
    printf "\n"
    print_color "$BOLD" "🤖 OpenCode agents that would be installed:"
    printf "\n"
    if [ -d "$opencode_base/agent" ]; then
      find "$opencode_base/agent" -name "*.md" -type f | while read -r agent_file; do
        local agent_name
        agent_name=$(basename "$agent_file" .md)
        print_color "$GREEN" "  + $agent_name.md"
      done
    fi

    # Show commands that would be installed
    printf "\n"
    print_color "$BOLD" "📋 OpenCode commands that would be installed:"
    printf "\n"
    if [ -d "$opencode_base/command" ]; then
      find "$opencode_base/command" -name "*.md" -type f | while read -r cmd_file; do
        local cmd_name
        cmd_name=$(basename "$cmd_file" .md)
        print_color "$GREEN" "  + $cmd_name.md"
      done
    fi

    # Show MCP servers that would be configured
    printf "\n"
    print_color "$BOLD" "🔌 MCP servers that would be configured in opencode.json:"
    printf "\n"
    if [ -f "$opencode_base/opencode.json" ]; then
      print_color "$CYAN" "  MCP servers from OpenCode configuration will be applied"
    fi

    # Show AGENTS.md that would be installed
    printf "\n"
    print_color "$BOLD" "📄 AGENTS.md file that would be installed to ~/.config/opencode/:"
    printf "\n"
    if [ -f "$repo_root/AGENTS.md" ]; then
      print_color "$GREEN" "  + AGENTS.md (configuration documentation)"
    fi
  else
    # Install OpenCode agents
    if [ -d "$opencode_base/agent" ]; then
      printf "\n"
      print_color "$BOLD" "Installing OpenCode Agents..."
      mkdir -p "$opencode_dir/agent"

      # Process each agent
      find "$opencode_base/agent" -name "*.md" -type f | while read -r agent_file; do
        local agent_name
        agent_name=$(basename "$agent_file" .md)
        if ! validate_path "$agent_name.md" "agent filename"; then
          log_error "Skipping invalid agent filename: $agent_name"
          continue
        fi
        local target_file="$opencode_dir/agent/${agent_name}.md"
        # Just copy the agent file directly
        local temp_file="/tmp/opencode_agent_${agent_name}_$$.md"
        cp "$agent_file" "$temp_file"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  $agent_name.md (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + $agent_name.md (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$temp_file" | sed 's/^/      /'
        fi

        log_info "Installing OpenCode agent: $agent_name"
        mv "$temp_file" "$target_file"
        log_success "Installed OpenCode agent: $agent_name.md"
      done
    fi

    # Install OpenCode commands
    if [ -d "$opencode_base/command" ]; then
      printf "\n"
      print_color "$BOLD" "Installing OpenCode Commands..."
      mkdir -p "$opencode_dir/command"

      # Process each command
      find "$opencode_base/command" -name "*.md" -type f | while read -r cmd_file; do
        local cmd_name
        cmd_name=$(basename "$cmd_file" .md)
        if ! validate_path "$cmd_name.md" "command filename"; then
          log_error "Skipping invalid command filename: $cmd_name"
          continue
        fi
        local target_file="$opencode_dir/command/${cmd_name}.md"
        # Just copy the command file directly
        local temp_file="/tmp/opencode_command_${cmd_name}_$$.md"
        cp "$cmd_file" "$temp_file"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  $cmd_name.md (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$temp_file" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          # Show preview of new file
          print_color "$GREEN" "  + $cmd_name.md (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$temp_file" | sed 's/^/      /'
        fi

        log_info "Installing OpenCode command: $cmd_name"
        mv "$temp_file" "$target_file"
        log_success "Installed OpenCode command: $cmd_name.md"
      done
    fi

    # Install AGENTS.md for OpenCode
    if [ -f "$repo_root/AGENTS.md" ]; then
      printf "\n"
      print_color "$BOLD" "Installing AGENTS.md for OpenCode..."
      local backup
      backup="${opencode_dir}/AGENTS.md.backup.$(date +%Y%m%d_%H%M%S)"
      local target_file="$opencode_dir/AGENTS.md"

      # Backup existing file if it exists
      if [ -f "$target_file" ]; then
        cp "$target_file" "$backup"
        log_info "Backed up existing AGENTS.md to: $backup"

        # Show diff
        print_color "$YELLOW" "  ⚠️  AGENTS.md (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/AGENTS.md" 2>/dev/null | head -20 | while IFS= read -r line; do
            case "$line" in
              +*) print_color "$GREEN" "    $line" ;;
              -*) print_color "$RED" "    $line" ;;
              @*) print_color "$CYAN" "    $line" ;;
              *) echo "    $line" ;;
            esac
          done
        fi
      else
        # Show preview of new file
        print_color "$GREEN" "  + AGENTS.md (new file)"
        print_color "$CYAN" "    Preview (first 10 lines):"
        head -10 "$repo_root/AGENTS.md" | sed 's/^/      /'
      fi

      cp "$repo_root/AGENTS.md" "$target_file"
      log_success "Installed AGENTS.md to ~/.config/opencode/"
    fi

    # Install or update OpenCode configuration
    printf "\n"
    print_color "$BOLD" "Installing OpenCode Configuration..."

    local opencode_config="$opencode_dir/opencode.json"

    # Merge OpenCode config using jq (override MCP definitions)
    if [ -f "$opencode_base/opencode.json" ]; then
      if [ -f "$opencode_config" ]; then
        # Backup existing config
        local backup
        backup="${opencode_config}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$opencode_config" "$backup"
        log_info "Backed up existing OpenCode config to: $backup"

        # Merge configurations but fully replace `.mcp` block when present
        jq -s '
          .[0] as $old | .[1] as $new |
          ($old * $new)
          | (if ($new | has("mcp")) then .mcp = $new.mcp else . end)
        ' "$opencode_config" "$opencode_base/opencode.json" > "${opencode_config}.tmp" && \
          mv "${opencode_config}.tmp" "$opencode_config"
        log_success "Updated OpenCode configuration (MCP overridden)"
      else
        # Copy new config
        cp "$opencode_base/opencode.json" "$opencode_config"
        log_success "Installed OpenCode configuration"
      fi

      # Show what was configured
      log_info "MCP servers configured:"
      jq -r '.mcp | keys[]' "$opencode_config" 2>/dev/null | while read -r server; do
        echo "  • $server"
      done
    fi

    # Update manifest to include OpenCode files
    local manifest="$claude_code_dir/.ai-rules-manifest.json"
    cat > "$manifest" <<EOF
{
  "version": "1.0",
  "installed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "source": "$repo_root",
  "configurations": [
    "settings.json",
    "agents/",
    "commands/",
    "CLAUDE.md"
  ],
  "codex_configurations": [
    "$codex_dir/config.toml",
    "$codex_dir/AGENTS.md"
  ],
  "gemini_configurations": [
    "$gemini_dir/AGENTS.md",
    "$gemini_dir/settings.json",
    "$gemini_dir/commands.toml"
  ],
  "opencode_configurations": [
    "$opencode_dir/agent/",
    "$opencode_dir/command/",
    "$opencode_dir/opencode.json",
    "$opencode_dir/AGENTS.md"
  ]
}
EOF
    log_success "Updated manifest with OpenCode configuration"
  fi

  printf "\n"

  # Install coreutils for timeout command (macOS)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    print_color "$BOLD" "=== Installing coreutils for timeout command ==="
    if [ "$dry_run" -eq 1 ]; then
      log_info "[DRY RUN] Would install coreutils via homebrew"
    else
      if ! command -v gtimeout >/dev/null 2>&1; then
        if command -v brew >/dev/null 2>&1; then
          log_info "Installing coreutils for timeout command..."
          if brew install coreutils 2>/dev/null; then
            log_success "Successfully installed coreutils"
            # Create symlink for timeout
            if ! command -v timeout >/dev/null 2>&1; then
              if ln -sf /opt/homebrew/bin/gtimeout /opt/homebrew/bin/timeout 2>/dev/null || \
                 ln -sf /usr/local/bin/gtimeout /usr/local/bin/timeout 2>/dev/null; then
                log_info "Created timeout symlink"
              else
                log_warning "Could not create timeout symlink - use gtimeout instead"
              fi
            fi
          else
            log_warning "Failed to install coreutils - timeout command unavailable"
          fi
        else
          log_warning "Homebrew not found - cannot install timeout command"
        fi
      else
        log_success "coreutils already installed"
      fi
    fi
    printf "\n"
  fi

  # Success message
  print_color "$BOLD$GREEN" "╔════════════════════════════════════════════╗"
  print_color "$BOLD$GREEN" "║     ${ROCKET} Installation Complete! ${ROCKET}        ║"
  print_color "$BOLD$GREEN" "╚════════════════════════════════════════════╝"
  printf "\n"

  log_success "AI Rules has been successfully installed!"
  log_info "Restart Claude Code, Codex CLI, Gemini CLI, and OpenCode to apply the new configurations."
  printf "\n"

  # Show what was installed
  print_color "$CYAN" "Installed configuration to:"
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    print_color "$YELLOW" "  • Claude Code: %USERPROFILE%\\.claude\\"
    print_color "$YELLOW" "  • Codex CLI: %USERPROFILE%\\.codex\\"
    print_color "$YELLOW" "  • Gemini CLI: %USERPROFILE%\\.gemini\\"
    print_color "$YELLOW" "  • OpenCode: %USERPROFILE%\\.config\\opencode\\"
  else
    print_color "$YELLOW" "  • Claude Code: ~/.claude/"
    print_color "$YELLOW" "  • Codex CLI: ~/.codex/"
    print_color "$YELLOW" "  • Gemini CLI: ~/.gemini/"
    print_color "$YELLOW" "  • OpenCode: ~/.config/opencode/"
  fi
  printf "\n"

  log_info "To uninstall, run: ./uninstall.sh"
}

# Run main function
main "$@"
