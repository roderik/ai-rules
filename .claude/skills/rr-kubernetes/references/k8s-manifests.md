# Kubernetes Manifest Generation Guide

Complete ten-step workflow for creating production-ready Kubernetes manifests.

## Step 1: Requirements Gathering

Assess application needs:
- **Application type**: Stateless (Deployment) vs stateful (StatefulSet)
- **Container image**: Registry, image name, specific tag (never `latest`)
- **Environment variables**: Configuration, secrets, feature flags
- **Storage needs**: Persistent data, logs, cache
- **Networking**: Internal only (ClusterIP) or external access (LoadBalancer/Ingress)
- **Resource requirements**: CPU, memory estimates
- **Scaling**: Fixed replicas or autoscaling based on load

## Step 2: Deployment Manifest Creation

Core workload structure with security and reliability:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: production
  labels:
    app: my-app
    version: v1.0.0
    environment: production
  annotations:
    description: "My production application"
spec:
  replicas: 3
  revisionHistoryLimit: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
        version: v1.0.0
    spec:
      # Pod-level security context
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault

      # Service account for RBAC
      serviceAccountName: my-app

      # Container specifications
      containers:
      - name: my-app
        image: my-registry/my-app:1.0.0
        imagePullPolicy: IfNotPresent

        # Ports
        ports:
        - name: http
          containerPort: 3000
          protocol: TCP

        # Environment configuration
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "3000"

        # ConfigMap and Secret references
        envFrom:
        - configMapRef:
            name: my-app-config
        - secretRef:
            name: my-app-secrets

        # Resource constraints (always set these!)
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi

        # Liveness probe (detects broken container)
        livenessProbe:
          httpGet:
            path: /health
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3

        # Readiness probe (detects when ready to receive traffic)
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3

        # Container-level security context
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000

        # Volume mounts (for read-only filesystem)
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /app/.cache

      # Volumes
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}

      # Node affinity and pod anti-affinity for HA
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - my-app
              topologyKey: kubernetes.io/hostname
```

## Step 3: Service Definition

Select service type based on access requirements:

### ClusterIP (Internal Access Only)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app
  namespace: production
  labels:
    app: my-app
spec:
  type: ClusterIP
  selector:
    app: my-app
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
  sessionAffinity: None
```

### LoadBalancer (External Access)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-external
  namespace: production
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
```

### Headless Service (StatefulSet)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-headless
  namespace: production
spec:
  clusterIP: None
  selector:
    app: my-app
  ports:
  - name: http
    port: 80
    targetPort: http
```

## Step 4: ConfigMap Generation

Store non-sensitive application configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
  namespace: production
  labels:
    app: my-app
data:
  # Simple key-value pairs
  LOG_LEVEL: "info"
  FEATURE_FLAG_X: "true"
  API_TIMEOUT: "30s"

  # Configuration files
  app.conf: |
    server {
      port = 3000
      workers = 4
    }

  # JSON configuration
  config.json: |
    {
      "database": {
        "pool_size": 10,
        "timeout": 30
      }
    }
```

## Step 5: Secret Management

Handle sensitive data with appropriate protection:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secrets
  namespace: production
  labels:
    app: my-app
type: Opaque
stringData:
  # Use stringData for plain text (will be base64 encoded automatically)
  DATABASE_URL: "postgresql://user:password@postgres:5432/mydb"
  API_KEY: "secret-api-key-value"
  JWT_SECRET: "super-secret-jwt-key"

# Or use data with base64-encoded values
# data:
#   DATABASE_URL: cG9zdGdyZXNxbDovL3VzZXI6cGFzc3dvcmRAcG9zdGdyZXM6NTQzMi9teWRi
```

**Best Practices:**
- Never commit secrets to git
- Use external secret management (Sealed Secrets, Vault, AWS Secrets Manager)
- Rotate secrets regularly
- Apply RBAC to limit secret access

## Step 6: PersistentVolumeClaim Creation

Configure stateful workload storage:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-app-data
  namespace: production
  labels:
    app: my-app
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 10Gi
```

**Access Modes:**
- `ReadWriteOnce` (RWO): Single node read/write
- `ReadOnlyMany` (ROX): Multiple nodes read-only
- `ReadWriteMany` (RWX): Multiple nodes read/write

**Storage Classes:**
- Check available storage classes: `kubectl get storageclass`
- Use appropriate class for workload (SSD vs HDD, regional vs zonal)

## Step 7: Security Implementation

Apply defense-in-depth security:

### Pod Security Context

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  fsGroupChangePolicy: "OnRootMismatch"
  seccompProfile:
    type: RuntimeDefault
```

### Container Security Context

```yaml
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
```

### ServiceAccount with RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app
  namespace: production
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-app-role
  namespace: production
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
  resourceNames: ["my-app-secrets"]
---
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

## Step 8: Labeling Strategy

Use standardized labels following Kubernetes conventions:

### Recommended Labels

```yaml
metadata:
  labels:
    # Kubernetes recommended labels
    app.kubernetes.io/name: my-app
    app.kubernetes.io/instance: my-app-prod
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/component: backend
    app.kubernetes.io/part-of: my-system
    app.kubernetes.io/managed-by: kubectl

    # Custom labels
    environment: production
    team: backend-team
    cost-center: engineering
```

### Selector Labels

```yaml
# Use simple, stable labels for selectors
selector:
  matchLabels:
    app: my-app
    environment: production
```

## Step 9: Multi-Resource Organization

Structure manifests for maintainability:

### Single File with Separators

```yaml
# all-resources.yaml
apiVersion: v1
kind: ConfigMap
...
---
apiVersion: v1
kind: Secret
...
---
apiVersion: apps/v1
kind: Deployment
...
---
apiVersion: v1
kind: Service
...
```

### Individual Files

```
manifests/
├── configmap.yaml
├── secret.yaml
├── deployment.yaml
├── service.yaml
└── ingress.yaml
```

### Kustomize Structure

```
k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── patches/
    └── production/
        ├── kustomization.yaml
        └── patches/
```

## Step 10: Validation Testing

Verify manifests before applying:

### Client-Side Validation

```bash
# Dry-run validation
kubectl apply -f manifests/ --dry-run=client

# Show what would be applied
kubectl apply -f manifests/ --dry-run=client -o yaml
```

### Server-Side Validation

```bash
# Validates against actual cluster
kubectl apply -f manifests/ --dry-run=server
```

### Kubeval (Schema Validation)

```bash
# Validate against Kubernetes schemas
kubeval manifests/*.yaml
kubeval --kubernetes-version 1.27.0 manifests/*.yaml
```

### Kube-linter (Security & Best Practices)

```bash
# Lint for security and best practices
kube-linter lint manifests/

# Specific checks
kube-linter lint manifests/ \
  --checks no-read-only-root-fs,run-as-non-root
```

### Diff Before Apply

```bash
# See what will change
kubectl diff -f manifests/

# With Kustomize
kubectl diff -k overlays/production/
```

## Common Manifest Patterns

### Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  namespace: production
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - my-app.example.com
    secretName: my-app-tls
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
```

### HorizontalPodAutoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
```

### StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: production
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 10Gi
```

## Troubleshooting Common Issues

### Pods Not Starting

```bash
kubectl get pods -n production
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
kubectl logs <pod-name> -n production --previous
```

### ImagePullBackOff

- Check image name and tag
- Verify image registry credentials
- Check imagePullSecrets

### CrashLoopBackOff

- Check application logs
- Verify resource limits
- Check liveness/readiness probes
- Review security context settings

### Pending Pods

- Check resource requests vs available resources
- Verify PVC binding
- Check node affinity rules
- Review pod security policies

## Manifest Generation Best Practices

1. **Always set resource requests and limits**
2. **Implement health probes** (liveness and readiness)
3. **Use specific image tags**, never `latest`
4. **Run containers as non-root**
5. **Enable read-only root filesystem**
6. **Apply pod anti-affinity** for high availability
7. **Use proper labeling strategy**
8. **Store configuration in ConfigMaps**
9. **Never commit secrets** to version control
10. **Validate before applying** (dry-run, kubeval, kube-linter)
