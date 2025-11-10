# Homebrew setup
# Detects and configures Homebrew for M-series vs Intel Macs

if test -e /opt/homebrew/bin/brew
    eval "$(/opt/homebrew/bin/brew shellenv)"
else if test -e /usr/local/bin/brew
    eval "$(/usr/local/bin/brew shellenv)"
end

# Homebrew completions
if command -q brew
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
end