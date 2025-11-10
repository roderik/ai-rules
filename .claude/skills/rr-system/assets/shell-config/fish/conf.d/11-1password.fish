# 1Password CLI Configuration
# Enable CLI completion for 1Password

if command -q op
    op completion fish | source
end