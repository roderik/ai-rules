# Prompt Configuration
# Initialize Starship prompt for interactive sessions

if [[ -o interactive ]] && command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi