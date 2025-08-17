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
  if [[ "$path" == *";"* ]] || [[ "$path" == *"|"* ]] || [[ "$path" == *"&"* ]] || \
     [[ "$path" == *'`'* ]] || [[ "$path" == *'$('* ]] || [[ "$path" == *">"* ]] || \
     [[ "$path" == *"<"* ]]; then
    printf "${RED}${ERROR} Invalid %s: Path contains potentially dangerous characters${NC}\n" "$description" >&2
    return 1
  fi

  return 0
}

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

# Display ASCII art with gradient colors
show_banner() {
  printf "\n"
  printf "${BLUE}     █████${CYAN}╗ ██${GREEN}╗    ██████${YELLOW}╗ ██${MAGENTA}╗   ██${RED}╗██${BLUE}╗     ███████${CYAN}╗███████${GREEN}╗${NC}\n"
  printf "${BLUE}    ██${CYAN}╔══██╗██${GREEN}║    ██${YELLOW}╔══██╗██${MAGENTA}║   ██${RED}║██${BLUE}║     ██${CYAN}╔════╝██${GREEN}╔════╝${NC}\n"
  printf "${BLUE}    ███████${CYAN}║██${GREEN}║    ██████${YELLOW}╔╝██${MAGENTA}║   ██${RED}║██${BLUE}║     █████${CYAN}╗  ███████${GREEN}╗${NC}\n"
  printf "${BLUE}    ██${CYAN}╔══██║██${GREEN}║    ██${YELLOW}╔══██╗██${MAGENTA}║   ██${RED}║██${BLUE}║     ██${CYAN}╔══╝  ╚════██${GREEN}║${NC}\n"
  printf "${BLUE}    ██${CYAN}║  ██║██${GREEN}║    ██${YELLOW}║  ██║╚██████${MAGENTA}╔╝███████${RED}╗███████${BLUE}╗███████${CYAN}║${NC}\n"
  printf "${BLUE}    ╚═${CYAN}╝  ╚═╝╚═${GREEN}╝    ╚═${YELLOW}╝  ╚═╝ ╚═════${MAGENTA}╝ ╚══════${RED}╝╚══════${BLUE}╝╚══════${CYAN}╝${NC}\n"
  printf "\n"
  printf "${BOLD}${MAGENTA}╔═══════════════════════════╗${NC}\n"
  printf "${BOLD}${CYAN}║      AI Rules Setup       ║${NC}\n"
  printf "${BOLD}${MAGENTA}╚═══════════════════════════╝${NC}\n"
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
  local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"

  # Create target directory if needed
  mkdir -p "$(dirname "$target")"

  # Backup existing file if it exists
  if [ -f "$target" ]; then
    cp "$target" "$backup"
    log_info "Backed up existing file to: $backup"
  fi

  # Merge or create
  if [ -f "$target" ]; then
    # Merge existing with new
    jq -s '.[0] * .[1]' "$target" "$source" > "${target}.tmp" && mv "${target}.tmp" "$target"
    log_success "Merged into: $target"
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
  local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"

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
  local force_overwrite=0
  local dry_run=0

  # Parse arguments
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --force)
        force_overwrite=1
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

    # Verify the cloned repository has the expected structure
    if [ ! -d "$src_base" ]; then
      log_error "Invalid repository structure: .claude directory not found"
      rm -rf "$temp_repo"
      exit 1
    fi

    log_success "Repository cloned successfully"

    # Set a flag to clean up the temp directory on exit
    trap "rm -rf '$temp_repo'" EXIT
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
    local temp_dir=$(mktemp -d)
    local before_file="$temp_dir/before.json"
    local after_file="$temp_dir/after.json"

    # Prepare the "before" state
    if [ -f "$claude_code_dir/settings.json" ]; then
      jq -S '.' "$claude_code_dir/settings.json" > "$before_file" 2>/dev/null || echo '{}' > "$before_file"
    else
      echo '{}' > "$before_file"
    fi

    # Prepare the "after" state by simulating the merge
    local merged_content=$(cat "$before_file")

    # Merge settings
    if [ -f "$src_base/settings/settings.json" ]; then
      merged_content=$(echo "$merged_content" | jq -s --slurpfile new "$src_base/settings/settings.json" '.[0] * $new[0]')
    fi

    # Merge hooks
    if [ -f "$src_base/hooks/hooks.json" ]; then
      merged_content=$(echo "$merged_content" | jq -s --slurpfile new "$src_base/hooks/hooks.json" '
        def merge_hook_arrays:
          . as [$existing, $new] |
          if ($existing | type) == "array" and ($new | type) == "array" then
            $existing + $new
          elif $new then
            $new
          else
            $existing
          end;

        .[0] as $base |
        $new[0].hooks as $new_hooks |
        $base | .hooks = (
          .hooks // {} |
          . as $existing_hooks |
          $new_hooks | to_entries | reduce .[] as $item (
            $existing_hooks;
            .[$item.key] = ([$existing_hooks[$item.key] // [], $item.value] | merge_hook_arrays)
          )
        )
      ')
    fi

    # Merge MCP servers
    if [ -f "$src_base/mcp/mcp.json" ]; then
      merged_content=$(echo "$merged_content" | jq -s --slurpfile new "$src_base/mcp/mcp.json" '.[0] * $new[0]')
    fi

    # Write the merged content to after file
    echo "$merged_content" | jq -S '.' > "$after_file"

    # Show the diff for settings.json
    print_color "$BOLD" "📝 Changes that would be made to settings.json:"
    printf "\n"

    if [ -f "$claude_code_dir/settings.json" ]; then
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
      find "$src_base/agents" -name "*.md" -type f | while read agent_file; do
        local agent_name=$(basename "$agent_file")
        if ! validate_path "$agent_name" "agent filename"; then
          log_error "Skipping invalid agent filename: $agent_name"
          continue
        fi
        local target_file="$claude_code_dir/agents/$agent_name"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  $agent_name (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            # Use delta with compact display
            diff -u --label "current" --label "new" "$target_file" "$agent_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$agent_file" 2>/dev/null | while IFS= read -r line; do
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
          print_color "$GREEN" "  + $agent_name (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$agent_file" | sed 's/^/      /'
        fi
      done
    fi

    # Show commands that would be installed with diff
    printf "\n"
    print_color "$BOLD" "📋 Commands that would be installed to ~/.claude/commands/:"
    printf "\n"
    if [ -d "$src_base/commands" ]; then
      find "$src_base/commands" -name "*.md" -type f | while read cmd_file; do
        local cmd_name=$(basename "$cmd_file")
        if ! validate_path "$cmd_name" "command filename"; then
          log_error "Skipping invalid command filename: $cmd_name"
          continue
        fi
        local target_file="$claude_code_dir/commands/$cmd_name"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  /$cmd_name (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            # Use delta with compact display
            diff -u --label "current" --label "new" "$target_file" "$cmd_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$cmd_file" 2>/dev/null | while IFS= read -r line; do
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
          print_color "$GREEN" "  + /$cmd_name (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$cmd_file" | sed 's/^/      /'
        fi
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
    # Merge settings.json
    if [ -f "$src_base/settings/settings.json" ]; then
      merge_json "$claude_code_dir/settings.json" "$src_base/settings/settings.json"
    fi

    # Merge hooks.json
    if [ -f "$src_base/hooks/hooks.json" ]; then
      merge_hooks "$claude_code_dir/settings.json" "$src_base/hooks/hooks.json"
    fi

    # Merge MCP servers into settings.json
    if [ -f "$src_base/mcp/mcp.json" ]; then
      local backup="${claude_code_dir}/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
      cp "$claude_code_dir/settings.json" "$backup"

      # Merge MCP servers into settings
      jq -s '.[0] * .[1]' "$claude_code_dir/settings.json" "$src_base/mcp/mcp.json" > "${claude_code_dir}/settings.json.tmp" && \
        mv "${claude_code_dir}/settings.json.tmp" "$claude_code_dir/settings.json"
      log_success "Merged MCP servers into settings.json"
    fi

    # Install agents
    if [ -d "$src_base/agents" ]; then
      printf "\n"
      print_color "$BOLD" "Installing AI Agents..."
      mkdir -p "$claude_code_dir/agents"
      find "$src_base/agents" -name "*.md" -type f | while read agent_file; do
        local agent_name=$(basename "$agent_file")
        if ! validate_path "$agent_name" "agent filename"; then
          log_error "Skipping invalid agent filename: $agent_name"
          continue
        fi
        local target_file="$claude_code_dir/agents/$agent_name"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  $agent_name (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$agent_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$agent_file" 2>/dev/null | head -20 | while IFS= read -r line; do
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
          print_color "$GREEN" "  + $agent_name (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$agent_file" | sed 's/^/      /'
        fi

        log_info "Copying agent: $agent_name to ~/.claude/agents/"
        cp "$agent_file" "$target_file"
        log_success "Installed agent: $agent_name"
      done
    fi

    # Install commands
    if [ -d "$src_base/commands" ]; then
      printf "\n"
      print_color "$BOLD" "Installing Custom Commands..."
      mkdir -p "$claude_code_dir/commands"
      find "$src_base/commands" -name "*.md" -type f | while read cmd_file; do
        local cmd_name=$(basename "$cmd_file")
        if ! validate_path "$cmd_name" "command filename"; then
          log_error "Skipping invalid command filename: $cmd_name"
          continue
        fi
        local target_file="$claude_code_dir/commands/$cmd_name"

        if [ -f "$target_file" ]; then
          # Show diff if file exists
          print_color "$YELLOW" "  ⚠️  /$cmd_name (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$cmd_file" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$cmd_file" 2>/dev/null | head -20 | while IFS= read -r line; do
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
          print_color "$GREEN" "  + /$cmd_name (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$cmd_file" | sed 's/^/      /'
        fi

        log_info "Copying command: $cmd_name to ~/.claude/commands/"
        cp "$cmd_file" "$target_file"
        log_success "Installed command: /$cmd_name"
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

    # Install output-styles
    if [ -d "$src_base/output-styles" ]; then
      printf "\n"
      print_color "$BOLD" "Installing Output Styles..."
      cp -r "$src_base/output-styles" "$claude_code_dir/"
      log_success "Installed output-styles to ~/.claude/"
    fi

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
    "output-styles/",
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
  else
    # Install Codex config.toml
    if [ -f "$codex_base/config.toml" ]; then
      mkdir -p "$codex_dir"
      local backup="${codex_dir}/config.toml.backup.$(date +%Y%m%d_%H%M%S)"
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
      local backup="${codex_dir}/AGENTS.md.backup.$(date +%Y%m%d_%H%M%S)"
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
    "$codex_dir/AGENTS.md"
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

    # Show GEMINI.md that would be installed
    printf "\n"
    print_color "$BOLD" "📄 GEMINI.md file that would be installed to ~/.gemini/:"
    printf "\n"
    if [ -f "$repo_root/GEMINI.md" ]; then
      local target_file="$gemini_dir/GEMINI.md"
      if [ -f "$target_file" ]; then
        # Show diff if file exists
        print_color "$YELLOW" "  ⚠️  GEMINI.md (already exists - showing diff):"
        if command -v delta >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/GEMINI.md" 2>/dev/null | \
            delta --no-gitconfig \
                  --paging=never \
                  --line-numbers \
                  --syntax-theme="Dracula" \
                  --width="${COLUMNS:-120}" \
                  --max-line-length=512 \
                  --diff-so-fancy \
                  --hyperlinks 2>/dev/null || true
        elif command -v diff >/dev/null 2>&1; then
          diff -u --label "current" --label "new" "$target_file" "$repo_root/GEMINI.md" 2>/dev/null | while IFS= read -r line; do
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
        print_color "$GREEN" "  + GEMINI.md (new file)"
        print_color "$CYAN" "    Preview (first 10 lines):"
        head -10 "$repo_root/GEMINI.md" | sed 's/^/      /'
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

      # Install GEMINI.md from root
      if [ -f "$repo_root/GEMINI.md" ]; then
        local backup="${gemini_dir}/GEMINI.md.backup.$(date +%Y%m%d_%H%M%S)"
        local target_file="$gemini_dir/GEMINI.md"

        # Backup existing file if it exists
        if [ -f "$target_file" ]; then
          cp "$target_file" "$backup"
          log_info "Backed up existing GEMINI.md to: $backup"

          # Show diff
          print_color "$YELLOW" "  ⚠️  GEMINI.md (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$repo_root/GEMINI.md" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy \
                    --hyperlinks 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$repo_root/GEMINI.md" 2>/dev/null | head -20 | while IFS= read -r line; do
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
          print_color "$GREEN" "  + GEMINI.md (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$repo_root/GEMINI.md" | sed 's/^/      /'
        fi

        cp "$repo_root/GEMINI.md" "$target_file"
        log_success "Installed GEMINI.md to ~/.gemini/"
      fi

      # Install settings.json
      if [ -f "$gemini_base/settings.json" ]; then
        local backup="${gemini_dir}/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
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
        local backup="${gemini_dir}/commands.toml.backup.$(date +%Y%m%d_%H%M%S)"
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
    "$gemini_dir/GEMINI.md",
    "$gemini_dir/settings.json",
    "$gemini_dir/commands.toml"
  ]
}
EOF
      log_success "Updated manifest: $manifest"
    fi
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

  # Install claude-code-docs
  print_color "$BOLD" "=== Installing Claude Code Docs ==="
  log_info "Installing claude-code-docs..."
  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would install claude-code-docs"
  else
    if curl -fsSL https://raw.githubusercontent.com/ericbuess/claude-code-docs/main/install.sh | bash; then
      log_success "Successfully installed claude-code-docs"
    else
      log_warning "Failed to install claude-code-docs (optional component)"
    fi
  fi

  printf "\n"

  # Success message
  print_color "$BOLD$GREEN" "╔════════════════════════════════════════════╗"
  print_color "$BOLD$GREEN" "║     ${ROCKET} Installation Complete! ${ROCKET}        ║"
  print_color "$BOLD$GREEN" "╚════════════════════════════════════════════╝"
  printf "\n"

  log_success "AI Rules has been successfully installed!"
  log_info "Restart Claude Code, Codex CLI, and Gemini CLI to apply the new configurations."
  printf "\n"

  # Show what was installed
  print_color "$CYAN" "Installed configuration to:"
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    print_color "$YELLOW" "  • Claude Code: %USERPROFILE%\\.claude\\"
    print_color "$YELLOW" "  • Codex CLI: %USERPROFILE%\\.codex\\"
    print_color "$YELLOW" "  • Gemini CLI: %USERPROFILE%\\.gemini\\"
  else
    print_color "$YELLOW" "  • Claude Code: ~/.claude/"
    print_color "$YELLOW" "  • Codex CLI: ~/.codex/"
    print_color "$YELLOW" "  • Gemini CLI: ~/.gemini/"
  fi
  printf "\n"

  log_info "To uninstall, run: ./uninstall.sh"
}

# Run main function
main "$@"