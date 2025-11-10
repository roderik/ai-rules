# Claude Function
# Custom Claude Code wrapper with auto-detection of project settings

function claude --description 'Claude Code with skip permissions'
  # Check if .claude/AUTO_PLAN_MODE.txt exists in current directory
  if test -f .claude/AUTO_PLAN_MODE.txt
    # Use the file content as system prompt
    command claude --dangerously-skip-permissions --append-system-prompt (cat .claude/AUTO_PLAN_MODE.txt | string collect) $argv
  else
    # Run normally without the append-system-prompt
    command claude --dangerously-skip-permissions $argv
  end
end

function opencode --description 'Opencode wrapper'
    env AGENT=1 command opencode $argv
end

alias oc="opencode"

# Codex function
function codex --description 'Codex wrapper'
    env AGENT=1 command codex --dangerously-bypass-approvals-and-sandbox $argv
end

# Cursor Agent function
function cursor-agent --description 'Cursor Agent wrapper'
    env AGENT=1 command cursor-agent -f $argv
end

# Gemini function
function gemini --description 'Gemini wrapper'
    env AGENT=1 command gemini -y $argv
end
