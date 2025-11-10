#!/usr/bin/env bash
# Foundry - Ethereum development toolkit configuration

# Add Foundry to PATH if installed
if [ -d "$HOME/.foundry/bin" ]; then
  export PATH="$HOME/.foundry/bin:$PATH"
fi

# Foundry aliases
if command -v forge &> /dev/null; then
  alias fb='forge build'
  alias ft='forge test'
  alias fc='forge clean'
  alias ff='forge fmt'
  alias fs='forge snapshot'
  alias fsc='forge script'
fi

if command -v cast &> /dev/null; then
  alias cb='cast balance'
  alias cs='cast send'
  alias cc='cast call'
fi

if command -v anvil &> /dev/null; then
  alias av='anvil'
  alias avf='anvil --fork-url'
fi