# Prompt Configuration
# Initialize Starship prompt for interactive sessions (cached)

if [[ -o interactive ]] && command -v starship &> /dev/null; then
  local cache_dir="${HOME}/.cache/zsh/hooks"
  local cache_file="${cache_dir}/starship.zsh"
  local tool_path="$(command -v starship)"

  if [[ ! -f "$cache_file" ]] || [[ "$tool_path" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    starship init zsh > "$cache_file" 2>/dev/null
  fi

  [[ -f "$cache_file" ]] && source "$cache_file"
fi