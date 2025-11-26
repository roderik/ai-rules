# Fish 4.x Features
# New features introduced in Fish 4.0+ (requires Fish 4.0 or later)

# Check Fish version (4.0+)
set -l fish_major (string match -r '^\d+' $version)
if test "$fish_major" -lt 4
    # Skip Fish 4.x features on older versions
    exit 0
end

# ═══════════════════════════════════════════════════════════════════════════════
# History Filtering (Fish 4.0+)
# ═══════════════════════════════════════════════════════════════════════════════
# Filter commands from history - they remain as temporary last entry but won't persist
# Useful for filtering sensitive commands or typos

function fish_should_add_to_history
    set -l raw_cmd $argv[1]

    # Don't save empty commands
    test -z "$raw_cmd" && return 1

    # Don't save commands starting with space (like bash HISTCONTROL=ignorespace)
    string match -q ' *' -- $raw_cmd && return 1

    # Trim for remaining checks
    set -l cmd (string trim -- $raw_cmd)

    # Extract just the first word (command name) for checks that need it
    set -l first_word (string split -m1 ' ' -- $cmd)[1]

    # Don't save very short commands (likely typos)
    test (string length -- "$first_word") -lt 2 && return 1

    # Filter commands with sensitive patterns
    # Tokens, passwords, secrets in environment variables or arguments
    string match -qr '(TOKEN|PASSWORD|SECRET|KEY|CREDENTIAL|API_KEY)=' -- $cmd && return 1

    # Filter common sensitive commands
    switch "$cmd"
        case 'export *TOKEN=*' 'export *PASSWORD=*' 'export *SECRET=*' 'export *KEY=*'
            return 1
        case 'set -gx *TOKEN *' 'set -gx *PASSWORD *' 'set -gx *SECRET *' 'set -gx *KEY *'
            return 1
        case 'op signin*' 'op item get*'
            # 1Password commands that might expose secrets
            return 1
    end

    # Allow everything else
    return 0
end

# ═══════════════════════════════════════════════════════════════════════════════
# Transient Prompt (Fish 4.1+ / Starship)
# ═══════════════════════════════════════════════════════════════════════════════
# Starship provides enable_transience function after init
# Define custom transient prompt that shows minimal character after execution

function starship_transient_prompt_func
    # Show just the character module (❯) for previously executed commands
    # Pass through all arguments from Starship (--terminal-width, --status, etc.)
    starship module character $argv
end

# Optional: transient right prompt - uncomment to show time on right
# function starship_transient_rprompt_func
#     starship module time $argv
# end

# ═══════════════════════════════════════════════════════════════════════════════
# Enhanced Key Bindings (Fish 4.0+)
# ═══════════════════════════════════════════════════════════════════════════════
# Fish 4.0 introduces human-readable key binding syntax
# Note: These work alongside existing bindings, not replacing them

if status is-interactive
    # Use new clear-commandline behavior (ctrl-c now clears without ^C marker)
    # To restore old behavior: bind ctrl-c cancel-commandline

    # Navigate by token (argument) instead of word
    # alt-left/right now do this by default on non-macOS, but we ensure it
    bind alt-left backward-token
    bind alt-right forward-token

    # ctrl-backspace to delete word (if terminal supports it via kitty protocol)
    bind ctrl-backspace backward-kill-word

    # Passive navigation (move without accepting autosuggestion)
    bind ctrl-alt-right forward-char-passive
    bind ctrl-alt-left backward-char-passive
end
