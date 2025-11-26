# Node.js Configuration
# Fast Node Manager setup (cached)

if command -v fnm &> /dev/null; then
  local cache_dir="${HOME}/.cache/zsh/hooks"
  local cache_file="${cache_dir}/fnm.zsh"
  local tool_path="$(command -v fnm)"

  if [[ ! -f "$cache_file" ]] || [[ "$tool_path" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    fnm env --use-on-cd > "$cache_file" 2>/dev/null
  fi

  [[ -f "$cache_file" ]] && source "$cache_file"
fi