# Homebrew setup
# Static configuration for M-series vs Intel Macs (no subprocess calls)

if test -e /opt/homebrew/bin/brew
    # Apple Silicon Mac
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    fish_add_path -gP /opt/homebrew/bin /opt/homebrew/sbin
    set -q MANPATH || set -gx MANPATH ''
    set -gx MANPATH /opt/homebrew/share/man $MANPATH
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
else if test -e /usr/local/bin/brew
    # Intel Mac
    set -gx HOMEBREW_PREFIX /usr/local
    set -gx HOMEBREW_CELLAR /usr/local/Cellar
    set -gx HOMEBREW_REPOSITORY /usr/local/Homebrew
    fish_add_path -gP /usr/local/bin /usr/local/sbin
    set -q MANPATH || set -gx MANPATH ''
    set -gx MANPATH /usr/local/share/man $MANPATH
    set -gx INFOPATH /usr/local/share/info $INFOPATH
end

# Homebrew completions (static paths)
if set -q HOMEBREW_PREFIX
    test -d "$HOMEBREW_PREFIX/share/fish/completions" && set -p fish_complete_path "$HOMEBREW_PREFIX/share/fish/completions"
    test -d "$HOMEBREW_PREFIX/share/fish/vendor_completions.d" && set -p fish_complete_path "$HOMEBREW_PREFIX/share/fish/vendor_completions.d"
end