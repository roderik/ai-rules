# Path Configuration
# Add various tool paths to Fish

# User local bin
fish_add_path -a "$HOME/.local/bin"

# Bun
if test -d "$HOME/.bun"
    set -gx BUN_INSTALL "$HOME/.bun"
    fish_add_path -a "$BUN_INSTALL/bin"
end

# Foundry
if test -d "$HOME/.foundry/bin"
    fish_add_path -a "$HOME/.foundry/bin"
end

# pnpm
if test -d "$HOME/Library/pnpm"
    set -gx PNPM_HOME "$HOME/Library/pnpm"
    fish_add_path -p "$PNPM_HOME"
end

# Kubernetes krew
if test -d "$HOME/.krew/bin"
    fish_add_path -a "$HOME/.krew/bin"
end