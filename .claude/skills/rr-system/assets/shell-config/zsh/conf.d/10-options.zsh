# Zsh Options

# Directory navigation
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push directories to stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack

# Completion
setopt COMPLETE_IN_WORD     # Complete from both ends
setopt ALWAYS_TO_END        # Move cursor to end after completion
setopt PATH_DIRS            # Path search for commands with /
setopt AUTO_MENU            # Show completion menu on tab
setopt AUTO_LIST            # List choices on ambiguous completion
setopt AUTO_PARAM_SLASH     # Add slash after directory completion
setopt MENU_COMPLETE        # Cycle through completions

# Correction
setopt CORRECT              # Command correction
setopt CORRECT_ALL          # Argument correction

# Globbing
setopt EXTENDED_GLOB        # Extended globbing
setopt GLOB_DOTS            # Include dotfiles in globbing
setopt NO_CASE_GLOB         # Case insensitive globbing

# Job control
setopt LONG_LIST_JOBS       # List jobs in long format
setopt NOTIFY               # Report status of bg jobs immediately
setopt NO_HUP               # Don't kill jobs on shell exit
setopt NO_CHECK_JOBS        # Don't warn about running jobs on exit

# Misc
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode
setopt NO_BEEP              # No beeping
setopt MULTIOS              # Multiple redirections
setopt PROMPT_SUBST         # Parameter expansion in prompt