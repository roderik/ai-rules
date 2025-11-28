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
