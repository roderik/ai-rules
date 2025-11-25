# GPG Agent configuration
# Set TTY for pinentry prompts

if command -v gpg &> /dev/null; then
  export GPG_TTY=$(tty)
fi
