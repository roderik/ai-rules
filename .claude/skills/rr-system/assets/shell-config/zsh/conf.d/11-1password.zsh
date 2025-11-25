# 1Password CLI configuration
# Completions are cached for performance

if command -v op &> /dev/null; then
  local cache_dir="${HOME}/.cache/zsh/completions"
  local cache_file="${cache_dir}/_op"
  local op_path="$(command -v op)"

  # Regenerate cache if it doesn't exist or op binary is newer
  if [[ ! -f "$cache_file" ]] || [[ "$op_path" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    op completion zsh > "$cache_file" 2>/dev/null
  fi

  # Add cache dir to fpath and load completion
  fpath=("$cache_dir" $fpath)
fi