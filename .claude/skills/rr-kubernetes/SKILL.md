---
name: rr-kubernetes
description: Comprehensive Kubernetes, Helm, and OpenShift operations skill. Use for creating production-ready K8s manifests, Helm charts, security policies, RBAC configurations, and OpenShift-specific resources. Also triggers when working with Kubernetes YAML files (.yaml, .yml), Helm chart files (Chart.yaml, values.yaml), or container orchestration configuration. Example triggers: "Create Kubernetes deployment", "Write Helm chart", "Set up RBAC", "Create K8s manifest", "Deploy to Kubernetes", "Configure OpenShift", "Add security policy"
---

# Kubernetes, Helm & OpenShift Operations

## Overview

Comprehensive skill for professional Kubernetes operations covering manifest generation, Helm chart development, security policy implementation, and OpenShift-specific patterns. Provides production-ready templates, security-first practices, and multi-environment deployment strategies.

## When to Use This Skill

Automatically activate when:
- Working with `.yaml`/`.yml` Kubernetes manifests
- User mentions Kubernetes, K8s, Helm, OpenShift, or container orchestration
- Helm chart detected (`Chart.yaml`, `values.yaml` present)
- User requests deployment creation, service configuration, or security policies
- Working with kubectl, helm, or oc commands
- Implementing cloud-native architectures or microservices deployments

## Core Workflows

### 1. Generate Kubernetes Manifests

Follow the ten-step workflow from `references/k8s-manifests.md`:

**Quick Start:**

```bash
# Generate a complete application stack
bash scripts/generate_manifest.sh my-app nodejs 3000
```

**Manual Creation - Production-Ready Deployment:**

Use templates from `assets/deployment-template.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
        version: v1.0.0
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: my-app
        image: my-app:1.0.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
```

**Validation before apply:**

```bash
kubectl apply -f manifests/ --dry-run=client
kubectl apply -f manifests/ --dry-run=server
kubeval manifests/*.yaml
kube-linter lint manifests/
```

### 2. Create Helm Charts

Follow chart scaffolding patterns from `references/helm-charts.md`:

**Initialize new chart:**

```bash
helm create my-app
# Or use scaffold script
bash scripts/scaffold_helm_chart.sh my-app nodejs
```

**Chart.yaml example:**

```yaml
apiVersion: v2
name: my-app
description: A production-ready application
type: application
version: 1.0.0
appVersion: "1.0.0"
dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
```

**Helm workflow:**

```bash
helm lint my-app/
helm template my-app my-app/ --values my-app/values.yaml
helm install my-app my-app/ --dry-run --debug
helm install my-app my-app/ --namespace my-namespace --create-namespace
helm upgrade --install my-app my-app/ --namespace my-namespace
```

### 3. Implement Security Policies

Follow security-first patterns from `references/security-policies.md`:

**Pod Security Standards:**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

**Network Policies:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

**RBAC Configuration:**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-app-role
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: my-app-binding
subjects:
- kind: ServiceAccount
  name: my-app
roleRef:
  kind: Role
  name: my-app-role
  apiGroup: rbac.authorization.k8s.io
```

### 4. OpenShift-Specific Resources

Follow OpenShift patterns from `references/openshift.md`:

**Route (OpenShift's Ingress):**

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app
spec:
  host: my-app.apps.cluster.example.com
  to:
    kind: Service
    name: my-app
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

**OpenShift commands:**

```bash
oc new-project my-app
oc new-app nodejs:16~https://github.com/example/my-app
oc expose svc/my-app
oc get route my-app
```

## Multi-Environment Strategy

**Directory structure:**

```
k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    ├── staging/
    └── production/
```

**Using Kustomize:**

```bash
kubectl kustomize k8s/overlays/production
kubectl apply -k k8s/overlays/production
```

**Helm values per environment:**

```bash
helm upgrade --install my-app ./my-app -f values-prod.yaml
helm upgrade --install my-app ./my-app -f values-prod.yaml --set image.tag=1.2.3
```

## Validation & Testing

**Pre-apply checklist:**

```bash
kubectl apply -f manifests/ --dry-run=client -o yaml
kubeval manifests/*.yaml
kube-linter lint manifests/
helm lint my-chart/
helm template my-release my-chart/ --debug
```

**Post-apply verification:**

```bash
kubectl get pods -n my-namespace
kubectl get events -n my-namespace --sort-by='.lastTimestamp'
kubectl logs -n my-namespace deployment/my-app
kubectl describe deployment my-app -n my-namespace
```

## Common Commands Reference

From `references/kubectl-commands.md`:

```bash
kubectl apply -f manifest.yaml
kubectl get pods
kubectl describe pod my-pod
kubectl logs my-pod
kubectl exec -it my-pod -- /bin/sh
kubectl port-forward pod/my-pod 8080:80

helm list
helm status my-release
helm rollback my-release 1
```

## Security Best Practices Summary

From `references/security-policies.md`:

1. **Pod Security Standards**: Apply `restricted` level to production namespaces
2. **Network Segmentation**: Implement default-deny network policies
3. **Least Privilege RBAC**: Grant minimal necessary permissions
4. **Non-Root Containers**: Always run as non-root user
5. **Read-Only Root Filesystem**: Mount writable volumes only where needed
6. **Drop Capabilities**: Drop ALL, add back only required capabilities
7. **Resource Limits**: Set CPU/memory requests and limits
8. **Image Security**: Never use `latest` tag, scan images regularly
9. **Secrets Management**: Use external secret stores (Vault, Sealed Secrets)
10. **Audit Logging**: Enable and monitor audit logs

## Resources

### scripts/
- `generate_manifest.sh` - Generate complete K8s manifest sets
- `scaffold_helm_chart.sh` - Scaffold production-ready Helm charts
- `validate_manifests.sh` - Validate manifests before applying

### references/
- `k8s-manifests.md` - Complete manifest generation guide with ten-step workflow
- `helm-charts.md` - Helm chart structure, templating, and best practices
- `security-policies.md` - Security policies, RBAC, and hardening guides
- `openshift.md` - OpenShift-specific resources and patterns
- `kubectl-commands.md` - kubectl and helm command reference

### assets/
- `deployment-template.yaml` - Production-ready Deployment template
- `service-templates.yaml` - ClusterIP, NodePort, LoadBalancer examples
- `helm-chart-template/` - Complete Helm chart boilerplate
- `network-policy-examples.yaml` - Common network policy patterns
- `rbac-templates.yaml` - ServiceAccount, Role, RoleBinding examples
- `openshift-templates.yaml` - Route, DeploymentConfig, ImageStream examples

## Workflow Example

Complete workflow for deploying a new microservice:

1. **Generate manifests** using scripts or templates
2. **Set resource limits** and health probes
3. **Configure security context** (non-root, read-only filesystem)
4. **Create ConfigMaps/Secrets** for configuration
5. **Define RBAC** with least privilege
6. **Add network policies** for traffic control
7. **Validate manifests**: `kubectl apply --dry-run=client`
8. **Security scan**: `kube-linter lint manifests/`
9. **Apply to dev**: `kubectl apply -k overlays/dev`
10. **Test thoroughly** in dev environment
11. **Promote to staging**: Update image tags, apply
12. **Production deployment**: Apply with approval gates

## Best Practices Summary

1. **Security First**: Non-root, read-only filesystem, network policies, RBAC
2. **Resource Limits**: Always set requests and limits
3. **Health Probes**: Implement liveness and readiness probes
4. **Immutable Tags**: Never use `latest`, use semantic versioning
5. **Declarative Config**: Store all manifests in version control
6. **Namespace Isolation**: Use namespaces for environment/team separation
7. **Validation**: Dry-run and lint before applying
8. **Monitoring**: Add labels for observability, implement logging
9. **Documentation**: Use annotations and labels consistently
10. **Automation**: CI/CD pipelines for consistent deployments
