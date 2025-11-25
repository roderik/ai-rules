# GPG Agent configuration
# Set TTY for pinentry prompts

if command -q gpg
    set -gx GPG_TTY (tty)
end
