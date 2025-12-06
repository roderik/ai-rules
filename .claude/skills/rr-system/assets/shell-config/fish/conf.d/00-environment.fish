# Environment Variables

# Terminal compatibility – only disable PDA queries when the terminal won't answer
function __fish_term_supports_pda --description 'returns 0 if PDA query is answered quickly'
  if not status --is-interactive
    return 0
  end

  set -l tty /dev/tty
  if not test -w $tty
    return 1
  end

  set -l stty_state (stty -g 2>/dev/null)
  printf '\e[c' >$tty 2>/dev/null
  read -t 0.2 -n 1 -- __resp <$tty
  set -l read_status $status

  if test -n "$stty_state"
    stty $stty_state 2>/dev/null
  end

  if test $read_status -ne 0
    return 1
  end

  test -n "$__resp"
end

function __fish_disable_term_queries_if_needed --description 'append no-query-term when PDA is unsupported'
  if contains -- no-query-term $fish_features
    return
  end

  set -l program (string lower -- "$TERM_PROGRAM")
  set -l disable_queries 0

  switch $program
    case vscode conductor
      set disable_queries 1
  end

  if test $disable_queries -eq 0
    if not __fish_term_supports_pda
      set disable_queries 1
    end
  end

  if test $disable_queries -eq 0
    return
  end

  if set -q fish_features
    set -g fish_features $fish_features no-query-term
  else
    set -g fish_features no-query-term
  end
end

__fish_disable_term_queries_if_needed

# Editor settings
set -x EDITOR nvim
set -x VISUAL nvim

# Node.js settings
set -x NODE_NO_WARNINGS 1

# Claude Code settings
set -x FORCE_AUTO_BACKGROUND_TASKS 1
set -x ENABLE_BACKGROUND_TASKS 1

# Homebrew settings
set -x HOMEBREW_NO_ENV_HINTS 1

# Path additions
fish_add_path ~/.local/bin
fish_add_path ~/bin

# FZF settings
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'

set fish_greeting
