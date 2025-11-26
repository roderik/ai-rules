# Node.js Configuration
# Fast Node Manager setup (cached)

if command -v fnm &> /dev/null; then
  _fnm_cache="$HOME/.cache/bash/hooks/fnm.bash"

  if [[ ! -f "$_fnm_cache" ]] || [[ "$(command -v fnm)" -nt "$_fnm_cache" ]]; then
    mkdir -p "$HOME/.cache/bash/hooks"
    fnm env --use-on-cd > "$_fnm_cache" 2>/dev/null
  fi

  [[ -f "$_fnm_cache" ]] && source "$_fnm_cache"
  unset _fnm_cache
fi