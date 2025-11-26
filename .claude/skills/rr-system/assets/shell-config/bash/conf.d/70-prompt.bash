# Prompt Configuration
# Initialize Starship prompt for interactive sessions (cached)

if [[ $- == *i* ]]; then
  if command -v starship &> /dev/null; then
    _starship_cache="$HOME/.cache/bash/hooks/starship.bash"

    if [[ ! -f "$_starship_cache" ]] || [[ "$(command -v starship)" -nt "$_starship_cache" ]]; then
      mkdir -p "$HOME/.cache/bash/hooks"
      # Use --print-full-init to get the actual init script, not just an eval command
      starship init bash --print-full-init > "$_starship_cache" 2>/dev/null
    fi

    [[ -f "$_starship_cache" ]] && source "$_starship_cache"
    unset _starship_cache
  fi
fi