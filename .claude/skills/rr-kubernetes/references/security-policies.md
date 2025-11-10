# Kubernetes Security Policies & Hardening Guide

Defense-in-depth security implementation covering Pod Security Standards, Network Policies, RBAC, and compliance best practices.

## Pod Security Standards

Kubernetes defines three standard policies at increasing restriction levels.

### Policy Levels

**Privileged** - Unrestricted, allows known privilege escalations
- Use for: System-level workloads, CNI plugins, CSI drivers
- Not recommended for applications

**Baseline** - Minimally restrictive, prevents known privilege escalations
- Disallows: Host namespaces, host ports, privileged mode
- Use for: Non-critical workloads during migration

**Restricted** - Heavily restricted, follows pod hardening best practices
- Requires: Non-root execution, read-only root filesystem, dropped capabilities
- Use for: All production applications (recommended)

### Namespace-Level Enforcement

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    # Enforce restricted policy (blocks non-compliant pods)
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest

    # Audit violations (logged but allowed)
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest

    # Warn users about violations
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
```

### Compliant Pod Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
spec:
  # Pod-level security context
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    fsGroupChangePolicy: "OnRootMismatch"
    seccompProfile:
      type: RuntimeDefault

  containers:
  - name: app
    image: my-app:1.0.0
    # Container-level security context
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
        # Add back only required capabilities
        # add:
        # - NET_BIND_SERVICE
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      runAsGroup: 1000
    # Mount writable volumes only where needed
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: cache
      mountPath: /app/.cache

  volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
```

## Network Policies

Control pod-to-pod and pod-to-external traffic.

### Default Deny All

```yaml
# Deny all ingress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
# Deny all egress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

### Allow Specific Traffic

```yaml
# Frontend can access backend
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
---
# Backend can access database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-database
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
```

### Allow DNS and External HTTPS

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-and-https
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  # Allow DNS queries
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Allow external HTTPS
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
  # Allow external HTTP
  - ports:
    - protocol: TCP
      port: 80
```

### Cross-Namespace Access

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-monitoring
  namespace: production
spec:
  podSelector:
    matchLabels:
      monitoring: "true"
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    - podSelector:
        matchLabels:
          app: prometheus
    ports:
    - protocol: TCP
      port: 9090
```

## RBAC (Role-Based Access Control)

### ServiceAccount, Role, and RoleBinding

```yaml
# ServiceAccount for application
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app
  namespace: production
---
# Role with minimal permissions
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-app-role
  namespace: production
rules:
# Read ConfigMaps
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
# Read specific Secret only
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
  resourceNames: ["my-app-secrets"]
# Read Pods for service discovery
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
# Bind Role to ServiceAccount
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: my-app-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: my-app
  namespace: production
roleRef:
  kind: Role
  name: my-app-role
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRole and ClusterRoleBinding

```yaml
# ClusterRole for cluster-wide resources
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
---
# Bind to ServiceAccount
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-reader-binding
subjects:
- kind: ServiceAccount
  name: log-collector
  namespace: monitoring
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Common RBAC Patterns

**Read-only access to namespace:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-reader
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
```

**CI/CD deployment permissions:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer
rules:
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "patch"]
```

## Resource Quotas and Limit Ranges

### ResourceQuota

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: production
spec:
  hard:
    # Limit total resources
    requests.cpu: "20"
    requests.memory: 40Gi
    limits.cpu: "40"
    limits.memory: 80Gi
    # Limit object counts
    pods: "50"
    services: "20"
    secrets: "100"
    configmaps: "100"
    persistentvolumeclaims: "20"
```

### LimitRange

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: production-limits
  namespace: production
spec:
  limits:
  # Container defaults and constraints
  - type: Container
    default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    min:
      cpu: 50m
      memory: 64Mi
    max:
      cpu: 2000m
      memory: 2Gi
  # Pod constraints
  - type: Pod
    max:
      cpu: 4000m
      memory: 8Gi
  # PVC constraints
  - type: PersistentVolumeClaim
    min:
      storage: 1Gi
    max:
      storage: 100Gi
```

## Secrets Management

### Sealed Secrets (Bitnami)

Encrypt secrets for safe storage in git:

```bash
# Install sealed-secrets controller
helm install sealed-secrets sealed-secrets/sealed-secrets -n kube-system

# Create sealed secret
echo -n "my-secret-value" | kubectl create secret generic my-secret \
  --dry-run=client --from-file=password=/dev/stdin -o yaml | \
  kubeseal -o yaml > sealed-secret.yaml

# Apply sealed secret
kubectl apply -f sealed-secret.yaml
# Controller decrypts and creates actual Secret
```

### External Secrets Operator

Sync secrets from external stores (Vault, AWS Secrets Manager, etc.):

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: production
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "my-app"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-app-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: my-app-secrets
    creationPolicy: Owner
  data:
  - secretKey: database-password
    remoteRef:
      key: production/database
      property: password
  - secretKey: api-key
    remoteRef:
      key: production/api
      property: key
```

## OPA Gatekeeper

Policy enforcement via admission control:

### Install Gatekeeper

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
```

### ConstraintTemplate

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels

        violation[{"msg": msg, "details": {"missing_labels": missing}}] {
          provided := {label | input.review.object.metadata.labels[label]}
          required := {label | label := input.parameters.labels[_]}
          missing := required - provided
          count(missing) > 0
          msg := sprintf("Missing required labels: %v", [missing])
        }
```

### Constraint

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-app-labels
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment", "StatefulSet"]
    namespaces: ["production"]
  parameters:
    labels:
      - "app"
      - "environment"
      - "owner"
```

## PodDisruptionBudget

Maintain availability during voluntary disruptions:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
  namespace: production
spec:
  minAvailable: 2
  # Or use maxUnavailable: 1
  selector:
    matchLabels:
      app: my-app
```

## Security Best Practices Checklist

### Pod Security
- [ ] Run as non-root user
- [ ] Read-only root filesystem
- [ ] Drop ALL capabilities, add back only required
- [ ] Disable privilege escalation
- [ ] Apply seccomp profile (RuntimeDefault)
- [ ] Set resource limits and requests
- [ ] Implement liveness and readiness probes

### Network Security
- [ ] Implement default-deny network policies
- [ ] Allow only required ingress/egress
- [ ] Isolate sensitive workloads
- [ ] Enable mutual TLS (service mesh)
- [ ] Use private container registries
- [ ] Scan images for vulnerabilities

### Access Control
- [ ] Use RBAC with least privilege
- [ ] ServiceAccount per application
- [ ] Never use default ServiceAccount
- [ ] Audit RBAC permissions regularly
- [ ] Enable audit logging
- [ ] Rotate credentials regularly

### Secrets & Config
- [ ] Never commit secrets to git
- [ ] Use external secret management
- [ ] Encrypt secrets at rest
- [ ] Rotate secrets regularly
- [ ] Use namespaces for isolation
- [ ] Apply resource quotas

### Image Security
- [ ] Use specific image tags (not latest)
- [ ] Sign and verify images
- [ ] Scan images in CI/CD
- [ ] Use minimal base images (distroless, alpine)
- [ ] Keep images updated
- [ ] Use private registries

### Cluster Security
- [ ] Enable Pod Security Standards
- [ ] Apply network policies
- [ ] Use admission controllers
- [ ] Enable audit logging
- [ ] Regular security updates
- [ ] Monitor security events

## Compliance Frameworks

### CIS Kubernetes Benchmark

Key controls:
- Control Plane: Secure API server, disable insecure port, enable RBAC
- etcd: Encrypt at rest, use TLS, limit access
- Worker Nodes: Secure kubelet, enable certificate rotation
- Policies: Enable PSP/PSS, network policies, resource quotas

### NIST Cybersecurity Framework

- **Identify**: Asset inventory, risk assessment
- **Protect**: Access control, data protection, security policies
- **Detect**: Anomaly detection, continuous monitoring, audit logs
- **Respond**: Incident response plans, communications, mitigation
- **Recover**: Recovery planning, improvements, communications

## Security Tools

### kube-bench

Audit cluster against CIS Benchmark:

```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
kubectl logs -f job/kube-bench
```

### kube-hunter

Hunt for security weaknesses:

```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-hunter/main/job.yaml
kubectl logs -f job/kube-hunter
```

### Trivy

Scan images for vulnerabilities:

```bash
trivy image my-registry/my-app:1.0.0
trivy k8s --report summary cluster
```

### Falco

Runtime security monitoring:

```bash
helm install falco falcosecurity/falco \
  --namespace falco --create-namespace \
  --set falco.grpc.enabled=true \
  --set falco.grpcOutput.enabled=true
```

## Emergency Response

### Quarantine Pod

```bash
# Apply restrictive network policy
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: quarantine-pod
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: suspicious-pod
  policyTypes:
  - Ingress
  - Egress
EOF

# Get forensic data
kubectl logs suspicious-pod > suspicious.log
kubectl exec suspicious-pod -- ps aux > suspicious-ps.txt

# Delete pod
kubectl delete pod suspicious-pod
```

### Revoke Access

```bash
# Delete compromised ServiceAccount
kubectl delete serviceaccount compromised-sa -n production

# Remove RoleBindings
kubectl delete rolebinding compromised-binding -n production

# Rotate secrets
kubectl delete secret compromised-secret -n production
# Recreate with new values
```

## Monitoring and Alerting

### Key Metrics to Monitor

- Failed authentication attempts
- Privilege escalation attempts
- Network policy violations
- Resource quota breaches
- Unauthorized API access
- Container escape attempts
- Suspicious process activity
- Unusual network traffic

### Alert on Security Events

```yaml
# Example Prometheus alert
groups:
- name: security
  rules:
  - alert: PrivilegedPodCreated
    expr: |
      kube_pod_container_status_running{container!=""}
      * on(pod, namespace) group_left
      kube_pod_spec_volumes_hostpath_readonly{readonly="false"} > 0
    for: 5m
    annotations:
      summary: "Privileged pod detected"
```
