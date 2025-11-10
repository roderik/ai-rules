# Fish Shell Configuration
# Location: ~/.config/fish/config.fish
#
# This is the main configuration file for Fish shell.
# All modular configurations are loaded from conf.d/
# Files in conf.d/ are loaded in alphabetical order.

# User-specific configuration
# Create ~/.config/fish/user_config.fish for personal customizations
if test -f ~/.config/fish/user_config.fish
    source ~/.config/fish/user_config.fish
end

# Note: Fish automatically loads all *.fish files from:
#   ~/.config/fish/conf.d/
# in alphabetical order, so most configuration is modular.