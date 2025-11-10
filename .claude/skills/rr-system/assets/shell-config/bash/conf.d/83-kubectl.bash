#!/usr/bin/env bash
# Kubernetes CLI (kubectl) configuration

# Enable kubectl completion if available
if command -v kubectl &> /dev/null; then
  source <(kubectl completion bash)
  
  # Add useful kubectl aliases
  alias k='kubectl'
  alias kgp='kubectl get pods'
  alias kgs='kubectl get services'
  alias kgd='kubectl get deployments'
  alias kaf='kubectl apply -f'
  alias kdel='kubectl delete'
  alias klog='kubectl logs'
  alias kexec='kubectl exec -it'
  
  # Enable completion for the 'k' alias
  complete -o default -F __start_kubectl k
fi