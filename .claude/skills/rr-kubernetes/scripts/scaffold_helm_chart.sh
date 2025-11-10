#!/usr/bin/env bash
#
# scaffold_helm_chart.sh - Scaffold production-ready Helm chart
#
# Usage: bash scaffold_helm_chart.sh <chart-name> [app-type]
#
# Example: bash scaffold_helm_chart.sh my-app nodejs
#

set -euo pipefail

# Parse arguments
CHART_NAME="${1:-}"
APP_TYPE="${2:-generic}"

if [ -z "$CHART_NAME" ]; then
  echo "Usage: $0 <chart-name> [app-type]"
  echo ""
  echo "Examples:"
  echo "  $0 my-app nodejs"
  echo "  $0 api python"
  echo ""
  echo "Supported app types: nodejs, python, java, go, generic"
  exit 1
fi

if [ -d "$CHART_NAME" ]; then
  echo "Error: Directory '$CHART_NAME' already exists"
  exit 1
fi

echo "Scaffolding Helm chart: $CHART_NAME"
echo "  App type: $APP_TYPE"
echo ""

# Create chart using helm create
if command -v helm &> /dev/null; then
  helm create "$CHART_NAME"
  echo "✅ Base chart structure created with 'helm create'"
else
  echo "⚠️  helm command not found, creating minimal structure"
  mkdir -p "$CHART_NAME"/{templates,charts}
fi

# Enhance Chart.yaml
cat > "$CHART_NAME/Chart.yaml" <<EOF
apiVersion: v2
name: ${CHART_NAME}
description: A production-ready ${APP_TYPE} application
type: application
version: 1.0.0
appVersion: "1.0.0"

keywords:
  - ${APP_TYPE}
  - microservice
  - kubernetes

home: https://github.com/example/${CHART_NAME}
sources:
  - https://github.com/example/${CHART_NAME}

maintainers:
  - name: Your Name
    email: you@example.com

# Optional dependencies (uncomment as needed)
# dependencies:
#   - name: postgresql
#     version: "12.x.x"
#     repository: "https://charts.bitnami.com/bitnami"
#     condition: postgresql.enabled
#   - name: redis
#     version: "17.x.x"
#     repository: "https://charts.bitnami.com/bitnami"
#     condition: redis.enabled
EOF

# Create comprehensive values.yaml
cat > "$CHART_NAME/values.yaml" <<EOF
# Default values for ${CHART_NAME}

replicaCount: 3

image:
  repository: ${CHART_NAME}
  pullPolicy: IfNotPresent
  tag: "1.0.0"

imagePullSecrets: []

nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: false
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  hosts:
    - host: ${CHART_NAME}.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: ${CHART_NAME}-tls
      hosts:
        - ${CHART_NAME}.example.com

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5

nodeSelector: {}

tolerations: []

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - ${CHART_NAME}
        topologyKey: kubernetes.io/hostname

env:
  - name: NODE_ENV
    value: production
  - name: PORT
    value: "8080"

envFrom: []

volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}

volumeMounts:
  - name: tmp
    mountPath: /tmp
  - name: cache
    mountPath: /app/.cache

podDisruptionBudget:
  enabled: true
  minAvailable: 2

# Dependencies configuration
# postgresql:
#   enabled: false
#   auth:
#     database: ${CHART_NAME}
#     username: ${CHART_NAME}

# redis:
#   enabled: false
#   auth:
#     enabled: false
EOF

# Create README
cat > "$CHART_NAME/README.md" <<EOF
# ${CHART_NAME} Helm Chart

Production-ready Helm chart for deploying ${CHART_NAME} to Kubernetes.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.8+

## Installing the Chart

\`\`\`bash
# Add chart repository (if published)
helm repo add myrepo https://charts.example.com
helm repo update

# Install chart
helm install ${CHART_NAME} ./${CHART_NAME}

# Install with custom values
helm install ${CHART_NAME} ./${CHART_NAME} -f values-prod.yaml

# Install in specific namespace
helm install ${CHART_NAME} ./${CHART_NAME} --namespace production --create-namespace
\`\`\`

## Uninstalling the Chart

\`\`\`bash
helm uninstall ${CHART_NAME}
\`\`\`

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| \`replicaCount\` | Number of replicas | \`3\` |
| \`image.repository\` | Container image repository | \`${CHART_NAME}\` |
| \`image.tag\` | Container image tag | \`1.0.0\` |
| \`service.port\` | Service port | \`80\` |
| \`ingress.enabled\` | Enable ingress | \`false\` |
| \`resources.requests.cpu\` | CPU request | \`100m\` |
| \`resources.requests.memory\` | Memory request | \`128Mi\` |
| \`autoscaling.enabled\` | Enable HPA | \`true\` |
| \`autoscaling.minReplicas\` | Minimum replicas | \`3\` |
| \`autoscaling.maxReplicas\` | Maximum replicas | \`10\` |

See \`values.yaml\` for full configuration options.

## Examples

### Development

\`\`\`bash
helm install ${CHART_NAME} ./${CHART_NAME} \\
  --set replicaCount=1 \\
  --set autoscaling.enabled=false \\
  --set image.tag=dev
\`\`\`

### Production

\`\`\`bash
helm install ${CHART_NAME} ./${CHART_NAME} \\
  --set image.tag=1.0.0 \\
  --set ingress.enabled=true \\
  --set ingress.hosts[0].host=${CHART_NAME}.example.com \\
  --set resources.requests.cpu=200m \\
  --set resources.requests.memory=256Mi
\`\`\`

## Validation

\`\`\`bash
# Lint chart
helm lint ./${CHART_NAME}

# Test template rendering
helm template ${CHART_NAME} ./${CHART_NAME}

# Dry-run install
helm install ${CHART_NAME} ./${CHART_NAME} --dry-run --debug
\`\`\`

## Upgrading

\`\`\`bash
# Upgrade release
helm upgrade ${CHART_NAME} ./${CHART_NAME}

# Upgrade with new values
helm upgrade ${CHART_NAME} ./${CHART_NAME} -f values-prod.yaml

# Upgrade or install (idempotent)
helm upgrade --install ${CHART_NAME} ./${CHART_NAME}
\`\`\`

## Testing

\`\`\`bash
# Run chart tests
helm test ${CHART_NAME}
\`\`\`
EOF

# Create .helmignore
cat > "$CHART_NAME/.helmignore" <<EOF
# Patterns to ignore when building packages
.git/
.gitignore
*.swp
*.bak
*.tmp
*.md
.DS_Store
values-*.yaml
*.example
EOF

# Add PDB template
cat > "$CHART_NAME/templates/pdb.yaml" <<'EOF'
{{- if .Values.podDisruptionBudget.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
spec:
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" . | nindent 6 }}
{{- end }}
EOF

echo "✅ Helm chart scaffolded successfully: $CHART_NAME/"
echo ""
echo "Next steps:"
echo "  1. Review and customize values.yaml"
echo "  2. Update Chart.yaml metadata"
echo "  3. Customize templates as needed"
echo "  4. Lint: helm lint $CHART_NAME/"
echo "  5. Test: helm template $CHART_NAME $CHART_NAME/"
echo "  6. Install: helm install $CHART_NAME $CHART_NAME/"
echo ""
echo "See $CHART_NAME/README.md for detailed instructions."
