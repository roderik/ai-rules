#!/usr/bin/env fish
# Kubernetes CLI (kubectl) configuration

# Enable kubectl completion if available
if type -q kubectl
    kubectl completion fish | source
    
    # Add useful kubectl aliases
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgd='kubectl get deployments'
    alias kaf='kubectl apply -f'
    alias kdel='kubectl delete'
    alias klog='kubectl logs'
    alias kexec='kubectl exec -it'
end