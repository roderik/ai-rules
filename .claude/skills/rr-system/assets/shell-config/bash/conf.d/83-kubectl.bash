#!/usr/bin/env bash
# Kubernetes CLI (kubectl) configuration

if command -v kubectl &> /dev/null; then
  # Use Homebrew-provided completion (already in bash_completion.d)
  # Fallback: cache completion if Homebrew version unavailable
  if [[ ! -f /opt/homebrew/etc/bash_completion.d/kubectl ]] && \
     [[ ! -f /usr/local/etc/bash_completion.d/kubectl ]]; then
    _kubectl_completion_cache="$HOME/.cache/bash/completions/kubectl.bash"

    if [[ ! -f "$_kubectl_completion_cache" ]] || [[ "$(command -v kubectl)" -nt "$_kubectl_completion_cache" ]]; then
      mkdir -p "$HOME/.cache/bash/completions"
      kubectl completion bash > "$_kubectl_completion_cache" 2>/dev/null
    fi

    [[ -f "$_kubectl_completion_cache" ]] && source "$_kubectl_completion_cache"
    unset _kubectl_completion_cache
  fi

  # Useful kubectl aliases
  alias k='kubectl'
  alias kgp='kubectl get pods'
  alias kgs='kubectl get services'
  alias kgd='kubectl get deployments'
  alias kaf='kubectl apply -f'
  alias kdel='kubectl delete'
  alias klog='kubectl logs'
  alias kexec='kubectl exec -it'

  # Enable completion for the 'k' alias
  complete -o default -F __start_kubectl k 2>/dev/null
fi
