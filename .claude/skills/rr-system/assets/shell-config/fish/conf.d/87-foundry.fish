#!/usr/bin/env fish
# Foundry - Ethereum development toolkit configuration

# Add Foundry to PATH if installed
if test -d "$HOME/.foundry/bin"
    set -gx PATH "$HOME/.foundry/bin" $PATH
end

# Foundry aliases
if type -q forge
    alias fb='forge build'
    alias ft='forge test'
    alias fc='forge clean'
    alias ff='forge fmt'
    alias fs='forge snapshot'
    alias fsc='forge script'
end

if type -q cast
    alias cb='cast balance'
    alias cs='cast send'
    alias cc='cast call'
end

if type -q anvil
    alias av='anvil'
    alias avf='anvil --fork-url'
end