# kubectl and Helm Command Reference

Quick reference for common kubectl and Helm commands.

## kubectl Basics

### Context and Configuration

```bash
# View current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context prod-cluster

# Set default namespace for context
kubectl config set-context --current --namespace=production

# View kubeconfig
kubectl config view

# Set kubeconfig file
export KUBECONFIG=~/.kube/config-prod
```

### Resource Management

```bash
# Apply resources
kubectl apply -f manifest.yaml
kubectl apply -f manifests/
kubectl apply -k overlays/production/

# Create resource (imperative)
kubectl create deployment nginx --image=nginx:1.25

# Delete resources
kubectl delete -f manifest.yaml
kubectl delete pod my-pod
kubectl delete all -l app=my-app

# Replace resource
kubectl replace -f manifest.yaml
kubectl replace --force -f manifest.yaml  # Delete and recreate
```

### Getting Resources

```bash
# List resources
kubectl get pods
kubectl get pods -n production
kubectl get pods --all-namespaces
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json
kubectl get pods -o jsonpath='{.items[0].metadata.name}'

# List all resource types
kubectl get all
kubectl get all -n production

# List specific resource types
kubectl get deployments,services,pods

# Watch resources
kubectl get pods -w
kubectl get pods --watch

# Show labels
kubectl get pods --show-labels

# Filter by labels
kubectl get pods -l app=my-app
kubectl get pods -l 'environment in (prod,staging)'
kubectl get pods -l environment!=dev
```

### Describing Resources

```bash
# Detailed information
kubectl describe pod my-pod
kubectl describe deployment my-app
kubectl describe node worker-1

# Show events
kubectl describe pod my-pod | grep Events -A 10

# Get events
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector type=Warning
```

### Logs

```bash
# View logs
kubectl logs my-pod
kubectl logs my-pod -c my-container  # Multi-container pod
kubectl logs -f my-pod  # Follow logs
kubectl logs --tail=100 my-pod  # Last 100 lines
kubectl logs --since=1h my-pod  # Last hour
kubectl logs --previous my-pod  # Previous container

# Logs from all pods with label
kubectl logs -l app=my-app

# Logs from deployment
kubectl logs deployment/my-app

# Logs with timestamps
kubectl logs my-pod --timestamps
```

### Exec and Debug

```bash
# Execute command
kubectl exec my-pod -- ls -la
kubectl exec my-pod -- env
kubectl exec my-pod -c my-container -- ps aux

# Interactive shell
kubectl exec -it my-pod -- /bin/bash
kubectl exec -it my-pod -- /bin/sh

# Debug pod
kubectl debug my-pod -it --image=busybox
kubectl debug node/worker-1 -it --image=ubuntu

# Run temporary pod
kubectl run debug --rm -it --image=busybox -- sh
kubectl run curl --rm -it --image=curlimages/curl -- sh
```

### Port Forwarding

```bash
# Forward local port to pod
kubectl port-forward pod/my-pod 8080:80
kubectl port-forward deployment/my-app 8080:80
kubectl port-forward service/my-app 8080:80

# Forward to specific address
kubectl port-forward --address 0.0.0.0 pod/my-pod 8080:80
```

### Copy Files

```bash
# Copy from pod
kubectl cp my-pod:/app/logs/app.log ./app.log
kubectl cp my-pod:/app/logs ./logs -c my-container

# Copy to pod
kubectl cp ./config.yaml my-pod:/app/config.yaml
```

### Resource Editing

```bash
# Edit resource
kubectl edit pod my-pod
kubectl edit deployment my-app

# Edit with specific editor
EDITOR=vim kubectl edit deployment my-app

# Patch resource
kubectl patch deployment my-app -p '{"spec":{"replicas":5}}'
kubectl patch pod my-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"nginx:1.26"}]'
```

### Scaling

```bash
# Scale deployment
kubectl scale deployment my-app --replicas=5

# Scale statefulset
kubectl scale statefulset postgres --replicas=3

# Auto-scale
kubectl autoscale deployment my-app --min=3 --max=10 --cpu-percent=70
```

### Rollouts

```bash
# Rollout status
kubectl rollout status deployment/my-app
kubectl rollout status statefulset/postgres

# Rollout history
kubectl rollout history deployment/my-app
kubectl rollout history deployment/my-app --revision=2

# Rollout undo
kubectl rollout undo deployment/my-app
kubectl rollout undo deployment/my-app --to-revision=2

# Rollout restart
kubectl rollout restart deployment/my-app

# Pause/Resume rollout
kubectl rollout pause deployment/my-app
kubectl rollout resume deployment/my-app
```

### Labels and Annotations

```bash
# Add label
kubectl label pod my-pod environment=production
kubectl label pod my-pod tier=backend

# Remove label
kubectl label pod my-pod environment-

# Update label
kubectl label pod my-pod environment=staging --overwrite

# Add annotation
kubectl annotate pod my-pod description="My application pod"

# Remove annotation
kubectl annotate pod my-pod description-
```

### Resource Usage

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods
kubectl top pods -n production
kubectl top pods --sort-by=memory
kubectl top pods --sort-by=cpu

# Container resources
kubectl top pod my-pod --containers
```

### Cluster Information

```bash
# Cluster info
kubectl cluster-info
kubectl cluster-info dump

# API resources
kubectl api-resources
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false

# API versions
kubectl api-versions

# Server version
kubectl version --short
```

### Namespaces

```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace production

# Delete namespace
kubectl delete namespace staging

# Set default namespace
kubectl config set-context --current --namespace=production
```

### ServiceAccounts and RBAC

```bash
# List ServiceAccounts
kubectl get serviceaccounts
kubectl get sa

# Create ServiceAccount
kubectl create serviceaccount my-app

# Get ServiceAccount token
kubectl create token my-app
kubectl create token my-app --duration=24h

# List roles
kubectl get roles
kubectl get clusterroles

# Describe role
kubectl describe role my-role

# Create role binding
kubectl create rolebinding my-binding \
  --role=my-role \
  --serviceaccount=production:my-app

# Check permissions
kubectl auth can-i create pods
kubectl auth can-i create pods --as=system:serviceaccount:production:my-app
```

### Secrets and ConfigMaps

```bash
# Create secret from literals
kubectl create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=secret

# Create secret from file
kubectl create secret generic my-secret \
  --from-file=./credentials.txt

# Create TLS secret
kubectl create secret tls my-tls-secret \
  --cert=tls.crt \
  --key=tls.key

# Create ConfigMap
kubectl create configmap my-config \
  --from-literal=LOG_LEVEL=info \
  --from-literal=FEATURE_X=true

# Create ConfigMap from file
kubectl create configmap my-config \
  --from-file=./config.yaml

# Get secret value
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 --decode

# Edit secret
kubectl edit secret my-secret
```

### Jobs and CronJobs

```bash
# Create job
kubectl create job my-job --image=busybox -- echo "Hello"

# Create CronJob
kubectl create cronjob my-cron \
  --image=busybox \
  --schedule="*/5 * * * *" \
  -- echo "Hello"

# List jobs
kubectl get jobs

# Delete completed jobs
kubectl delete jobs --field-selector status.successful=1
```

### Validation and Dry-Run

```bash
# Client-side dry-run
kubectl apply -f manifest.yaml --dry-run=client

# Server-side dry-run
kubectl apply -f manifest.yaml --dry-run=server

# Show diff
kubectl diff -f manifest.yaml

# Validate YAML
kubectl apply -f manifest.yaml --validate=true --dry-run=client
```

### Advanced Queries

```bash
# JSONPath examples
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{.items[*].status.podIP}'
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'

# Custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP

# Sort by timestamp
kubectl get pods --sort-by=.metadata.creationTimestamp

# Filter by field selector
kubectl get pods --field-selector status.phase=Running
kubectl get events --field-selector involvedObject.name=my-pod
```

## Helm Commands

### Repository Management

```bash
# Add repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add stable https://charts.helm.sh/stable

# Update repositories
helm repo update

# List repositories
helm repo list

# Remove repository
helm repo remove bitnami

# Search repository
helm search repo nginx
helm search repo bitnami/postgresql
helm search hub wordpress
```

### Chart Management

```bash
# Create new chart
helm create my-app

# Lint chart
helm lint my-app/

# Package chart
helm package my-app/
helm package my-app/ --destination ./dist

# Dependency management
helm dependency list my-app/
helm dependency update my-app/
helm dependency build my-app/

# Show chart info
helm show chart bitnami/postgresql
helm show values bitnami/postgresql
helm show readme bitnami/postgresql
helm show all bitnami/postgresql
```

### Installation

```bash
# Install chart
helm install my-release ./my-app
helm install my-release bitnami/postgresql

# Install with namespace
helm install my-release ./my-app --namespace production --create-namespace

# Install with custom values
helm install my-release ./my-app -f values-prod.yaml
helm install my-release ./my-app --set replicaCount=5
helm install my-release ./my-app --set image.tag=1.2.3

# Install with multiple values files
helm install my-release ./my-app \
  -f values.yaml \
  -f values-prod.yaml \
  -f values-secrets.yaml

# Dry-run install
helm install my-release ./my-app --dry-run --debug

# Generate manifest only
helm template my-release ./my-app
helm template my-release ./my-app -f values-prod.yaml
helm template my-release ./my-app --show-only templates/deployment.yaml
```

### Upgrade

```bash
# Upgrade release
helm upgrade my-release ./my-app

# Upgrade with values
helm upgrade my-release ./my-app -f values-prod.yaml

# Upgrade or install (idempotent)
helm upgrade --install my-release ./my-app

# Atomic upgrade (rollback on failure)
helm upgrade my-release ./my-app --atomic

# Wait for resources
helm upgrade my-release ./my-app --wait --timeout 10m

# Force update
helm upgrade my-release ./my-app --force

# Recreate pods
helm upgrade my-release ./my-app --recreate-pods
```

### Release Management

```bash
# List releases
helm list
helm list --all-namespaces
helm list --namespace production
helm list --all  # Include deleted

# Get release status
helm status my-release

# Get release values
helm get values my-release
helm get values my-release --all
helm get values my-release --revision 2

# Get release manifest
helm get manifest my-release

# Get release notes
helm get notes my-release

# Release history
helm history my-release

# Rollback release
helm rollback my-release
helm rollback my-release 1
helm rollback my-release 1 --wait

# Uninstall release
helm uninstall my-release
helm uninstall my-release --keep-history
helm uninstall my-release --namespace production
```

### OCI Registry

```bash
# Login to registry
helm registry login registry.example.com -u username

# Push chart
helm push my-app-1.0.0.tgz oci://registry.example.com/charts

# Pull chart
helm pull oci://registry.example.com/charts/my-app --version 1.0.0

# Install from OCI
helm install my-release oci://registry.example.com/charts/my-app --version 1.0.0

# List images
crane ls registry.example.com/charts
```

### Plugin Management

```bash
# List plugins
helm plugin list

# Install plugin
helm plugin install https://github.com/databus23/helm-diff

# Update plugin
helm plugin update diff

# Uninstall plugin
helm plugin uninstall diff
```

### Troubleshooting

```bash
# Test release
helm test my-release
helm test my-release --logs

# Get all info
helm get all my-release

# Debug template rendering
helm template my-release ./my-app --debug

# Verify chart
helm lint my-app/ --strict

# Check chart for issues
helm lint my-app/ --with-subcharts
```

## Useful Aliases

Add to `.bashrc` or `.zshrc`:

```bash
# kubectl aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias ka='kubectl apply -f'
alias kdel='kubectl delete'
alias keti='kubectl exec -ti'

# Context aliases
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# Helm aliases
alias h='helm'
alias hi='helm install'
alias hu='helm upgrade'
alias hls='helm list'
alias hst='helm status'
```

## Productivity Tips

### Quick Pod Shell

```bash
kubectl run tmp --rm -it --image=busybox -- sh
kubectl run tmp --rm -it --image=ubuntu -- bash
kubectl run tmp --rm -it --image=nicolaka/netshoot -- bash
```

### One-liners

```bash
# Get all pod IPs
kubectl get pods -o wide | awk '{print $6}' | tail -n +2

# Delete all evicted pods
kubectl get pods | grep Evicted | awk '{print $1}' | xargs kubectl delete pod

# Get image for all pods
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

# Count pods by status
kubectl get pods -A | tail -n +2 | awk '{print $4}' | sort | uniq -c

# Get pods not ready
kubectl get pods --field-selector=status.phase!=Running

# Watch deployment rollout
watch kubectl get pods -l app=my-app
```

### Shell Functions

Add to `.bashrc` or `.zshrc`:

```bash
# Get pod by partial name
kgpn() {
  kubectl get pods | grep $1 | head -1 | awk '{print $1}'
}

# Shell into pod by partial name
kshell() {
  kubectl exec -it $(kgpn $1) -- /bin/bash
}

# Logs of pod by partial name
klog() {
  kubectl logs -f $(kgpn $1)
}

# Delete pod by partial name
kdelpod() {
  kubectl delete pod $(kgpn $1)
}
```

## Common Workflows

### Deploy New Version

```bash
# Update image
kubectl set image deployment/my-app my-app=my-app:1.2.0

# Watch rollout
kubectl rollout status deployment/my-app

# Verify
kubectl get pods -l app=my-app

# Check logs
kubectl logs -f deployment/my-app
```

### Troubleshoot Pod Issues

```bash
# Get pod status
kubectl get pod my-pod

# Describe pod
kubectl describe pod my-pod

# Check events
kubectl get events --field-selector involvedObject.name=my-pod

# Check logs
kubectl logs my-pod
kubectl logs my-pod --previous

# Shell into pod
kubectl exec -it my-pod -- sh

# Debug with ephemeral container
kubectl debug my-pod -it --image=busybox
```

### Scale Application

```bash
# Manual scale
kubectl scale deployment my-app --replicas=5

# Auto-scale
kubectl autoscale deployment my-app --min=3 --max=10 --cpu-percent=70

# Check HPA
kubectl get hpa

# Check current replicas
kubectl get deployment my-app -o jsonpath='{.spec.replicas}'
```

### Update Configuration

```bash
# Update ConfigMap
kubectl create configmap my-config --from-literal=KEY=VALUE --dry-run=client -o yaml | kubectl apply -f -

# Rollout restart to pick up new config
kubectl rollout restart deployment/my-app

# Verify
kubectl rollout status deployment/my-app
```
