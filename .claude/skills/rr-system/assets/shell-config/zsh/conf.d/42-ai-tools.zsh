# AI Tool Functions

# Claude function with AUTO_PLAN_MODE support
claude() {
  local args=("$@")
  local extra_args=()

  # Check if .claude/AUTO_PLAN_MODE.txt exists in current directory
  if [[ -f .claude/AUTO_PLAN_MODE.txt ]]; then
    # Use the file content as system prompt
    local prompt_content=$(cat .claude/AUTO_PLAN_MODE.txt)
    extra_args+=("--append-system-prompt" "$prompt_content")
  fi

  command claude --dangerously-skip-permissions "${extra_args[@]}" "${args[@]}"
}

# Codex function
codex() {
  AGENT=1 command codex --dangerously-bypass-approvals-and-sandbox "$@"
}

# Cursor Agent function
cursor-agent() {
  AGENT=1 command cursor-agent -f "$@"
}

# Gemini function
gemini() {
  AGENT=1 command gemini -y "$@"
}

# Opencode function
opencode() {
  AGENT=1 command opencode "$@"
}

alias oc="opencode"