# Kubernetes CLI (kubectl) configuration
# Completions are provided by Homebrew in site-functions

if command -v kubectl &> /dev/null; then
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
  compdef k=kubectl
fi