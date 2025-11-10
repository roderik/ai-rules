#!/usr/bin/env bash
# Claude Function
# Custom Claude Code wrapper with auto-detection of project settings

claude() {
  # Check if .claude/AUTO_PLAN_MODE.txt exists in current directory
  if [[ -f .claude/AUTO_PLAN_MODE.txt ]]; then
    # Use the file content as system prompt
    local prompt_content=$(cat .claude/AUTO_PLAN_MODE.txt)
    command claude --dangerously-skip-permissions --append-system-prompt "$prompt_content" "$@"
  else
    # Run normally without the append-system-prompt
    command claude --dangerously-skip-permissions "$@"
  fi
}

# Opencode function
opencode() {
  AGENT=1 command opencode "$@"
}

alias oc="opencode"

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