#!/usr/bin/env bash
#
# generate_manifest.sh - Generate production-ready Kubernetes manifests
#
# Usage: bash generate_manifest.sh <app-name> <app-type> <port> [namespace]
#
# Example: bash generate_manifest.sh my-app nodejs 3000 production
#

set -euo pipefail

# Parse arguments
APP_NAME="${1:-}"
APP_TYPE="${2:-generic}"
PORT="${3:-8080}"
NAMESPACE="${4:-default}"

if [ -z "$APP_NAME" ]; then
  echo "Usage: $0 <app-name> <app-type> <port> [namespace]"
  echo ""
  echo "Examples:"
  echo "  $0 my-app nodejs 3000 production"
  echo "  $0 api python 8000"
  echo ""
  echo "Supported app types: nodejs, python, java, go, generic"
  exit 1
fi

OUTPUT_DIR="k8s-manifests-${APP_NAME}"
mkdir -p "$OUTPUT_DIR"

echo "Generating Kubernetes manifests for: $APP_NAME"
echo "  Type: $APP_TYPE"
echo "  Port: $PORT"
echo "  Namespace: $NAMESPACE"
echo "  Output: $OUTPUT_DIR/"
echo ""

# Generate Deployment
cat > "$OUTPUT_DIR/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
    app.kubernetes.io/name: ${APP_NAME}
    app.kubernetes.io/component: application
spec:
  replicas: 3
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: ${APP_NAME}
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: ${APP_NAME}
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "${PORT}"
        prometheus.io/path: "/metrics"
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      serviceAccountName: ${APP_NAME}
      containers:
      - name: ${APP_NAME}
        image: ${APP_NAME}:latest  # TODO: Replace with actual image
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: ${PORT}
          protocol: TCP
        env:
        - name: PORT
          value: "${PORT}"
        envFrom:
        - configMapRef:
            name: ${APP_NAME}-config
        - secretRef:
            name: ${APP_NAME}-secrets
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
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
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
                  - ${APP_NAME}
              topologyKey: kubernetes.io/hostname
EOF

# Generate Service
cat > "$OUTPUT_DIR/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
spec:
  type: ClusterIP
  selector:
    app: ${APP_NAME}
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
  sessionAffinity: None
EOF

# Generate ConfigMap
cat > "$OUTPUT_DIR/configmap.yaml" <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${APP_NAME}-config
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
data:
  LOG_LEVEL: "info"
  NODE_ENV: "production"
  # Add application-specific configuration here
EOF

# Generate Secret (placeholder)
cat > "$OUTPUT_DIR/secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${APP_NAME}-secrets
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
type: Opaque
stringData:
  # TODO: Replace with actual secrets
  # Never commit secrets to git!
  # Use external secret management (Vault, Sealed Secrets, etc.)
  DATABASE_URL: "postgresql://user:CHANGEME@postgres:5432/db"
  API_KEY: "CHANGEME"
EOF

# Generate ServiceAccount
cat > "$OUTPUT_DIR/serviceaccount.yaml" <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
EOF

# Generate RBAC
cat > "$OUTPUT_DIR/rbac.yaml" <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${APP_NAME}-role
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
  resourceNames: ["${APP_NAME}-secrets"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${APP_NAME}-binding
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
subjects:
- kind: ServiceAccount
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
roleRef:
  kind: Role
  name: ${APP_NAME}-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Generate HPA
cat > "$OUTPUT_DIR/hpa.yaml" <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${APP_NAME}
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
EOF

# Generate PDB
cat > "$OUTPUT_DIR/pdb.yaml" <<EOF
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: ${APP_NAME}
EOF

# Generate Ingress (optional)
cat > "$OUTPUT_DIR/ingress.yaml" <<EOF
# Optional: Uncomment and configure for external access
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: ${APP_NAME}
#   namespace: ${NAMESPACE}
#   labels:
#     app: ${APP_NAME}
#   annotations:
#     cert-manager.io/cluster-issuer: letsencrypt-prod
#     nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
# spec:
#   ingressClassName: nginx
#   tls:
#   - hosts:
#     - ${APP_NAME}.example.com
#     secretName: ${APP_NAME}-tls
#   rules:
#   - host: ${APP_NAME}.example.com
#     http:
#       paths:
#       - path: /
#         pathType: Prefix
#         backend:
#           service:
#             name: ${APP_NAME}
#             port:
#               number: 80
EOF

# Generate README
cat > "$OUTPUT_DIR/README.md" <<EOF
# ${APP_NAME} Kubernetes Manifests

Generated manifests for deploying ${APP_NAME} to Kubernetes.

## Files

- \`deployment.yaml\` - Main application Deployment
- \`service.yaml\` - Service for internal access
- \`configmap.yaml\` - Application configuration
- \`secret.yaml\` - Sensitive configuration (DO NOT COMMIT!)
- \`serviceaccount.yaml\` - ServiceAccount for the application
- \`rbac.yaml\` - Role and RoleBinding for least-privilege access
- \`hpa.yaml\` - HorizontalPodAutoscaler for auto-scaling
- \`pdb.yaml\` - PodDisruptionBudget for high availability
- \`ingress.yaml\` - Optional Ingress for external access

## Before Applying

1. **Update image reference** in \`deployment.yaml\`
2. **Update secrets** in \`secret.yaml\` (use external secret management!)
3. **Configure ingress** in \`ingress.yaml\` if needed
4. **Adjust resource limits** based on your application needs
5. **Update health check paths** if not /health and /ready

## Validation

\`\`\`bash
# Dry-run validation
kubectl apply -f . --dry-run=client

# Server-side validation
kubectl apply -f . --dry-run=server

# Lint with kubeval (if installed)
kubeval *.yaml

# Security scan with kube-linter (if installed)
kube-linter lint .
\`\`\`

## Deploy

\`\`\`bash
# Apply all manifests
kubectl apply -f .

# Check deployment status
kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE}

# Check pods
kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME}

# Check logs
kubectl logs -f deployment/${APP_NAME} -n ${NAMESPACE}
\`\`\`

## Security Considerations

- [ ] Secrets managed externally (Vault, Sealed Secrets, etc.)
- [ ] Image uses specific tag (not \`latest\`)
- [ ] Resource limits configured appropriately
- [ ] Network policies applied if needed
- [ ] Image scanned for vulnerabilities
- [ ] Health probes configured correctly

## Monitoring

\`\`\`bash
# Watch pods
kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} -w

# View events
kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp'

# Check HPA status
kubectl get hpa ${APP_NAME} -n ${NAMESPACE}

# Check resource usage
kubectl top pods -n ${NAMESPACE} -l app=${APP_NAME}
\`\`\`
EOF

echo "✅ Manifests generated successfully in: $OUTPUT_DIR/"
echo ""
echo "Next steps:"
echo "  1. Review and customize generated manifests"
echo "  2. Update image reference in deployment.yaml"
echo "  3. Configure secrets (use external secret management!)"
echo "  4. Validate: kubectl apply -f $OUTPUT_DIR/ --dry-run=client"
echo "  5. Apply: kubectl apply -f $OUTPUT_DIR/"
echo ""
echo "See $OUTPUT_DIR/README.md for detailed instructions."
