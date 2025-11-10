# Helm Charts Guide

Complete guide for creating production-ready Helm charts with templating, dependency management, and multi-environment support.

## Chart Structure

Standard Helm chart directory structure:

```
my-app/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration values
├── charts/                 # Chart dependencies
├── templates/              # Kubernetes manifest templates
│   ├── NOTES.txt           # Post-install notes
│   ├── _helpers.tpl        # Template helpers
│   ├── deployment.yaml     # Deployment template
│   ├── service.yaml        # Service template
│   ├── ingress.yaml        # Ingress template
│   ├── configmap.yaml      # ConfigMap template
│   ├── secret.yaml         # Secret template
│   ├── serviceaccount.yaml # ServiceAccount template
│   ├── hpa.yaml            # HorizontalPodAutoscaler
│   ├── pdb.yaml            # PodDisruptionBudget
│   └── tests/              # Chart tests
│       └── test-connection.yaml
├── .helmignore             # Files to ignore
└── README.md               # Chart documentation
```

## Chart.yaml Metadata

Define chart metadata and dependencies:

```yaml
apiVersion: v2
name: my-app
description: A production-ready microservice application
type: application              # application or library
version: 1.0.0                 # Chart version (SemVer)
appVersion: "1.0.0"            # Application version

# Optional metadata
keywords:
  - nodejs
  - microservice
  - api
home: https://github.com/example/my-app
sources:
  - https://github.com/example/my-app
maintainers:
  - name: Your Name
    email: you@example.com
    url: https://example.com
icon: https://example.com/icon.png
deprecated: false
annotations:
  category: Application
  licenses: Apache-2.0

# Chart dependencies
dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
    tags:
      - database
  - name: redis
    version: 17.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
    tags:
      - cache
  - name: common
    version: 2.x.x
    repository: https://charts.bitnami.com/bitnami
    # Library charts for shared templates
```

## values.yaml Configuration

Comprehensive default values structure:

```yaml
# Replica configuration
replicaCount: 3

# Image configuration
image:
  repository: my-app
  pullPolicy: IfNotPresent
  tag: "1.0.0"  # Override with .Chart.AppVersion if empty

# Image pull secrets for private registries
imagePullSecrets: []
# - name: my-registry-secret

# Override chart name
nameOverride: ""
fullnameOverride: ""

# ServiceAccount configuration
serviceAccount:
  create: true
  annotations: {}
  name: ""

# Pod annotations
podAnnotations: {}

# Pod security context
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

# Container security context
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

# Service configuration
service:
  type: ClusterIP
  port: 80
  targetPort: 3000
  annotations: {}

# Ingress configuration
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  hosts:
    - host: my-app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: my-app-tls
      hosts:
        - my-app.example.com

# Resource limits and requests
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

# Horizontal Pod Autoscaling
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

# Health probes
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

# Node selector
nodeSelector: {}

# Tolerations
tolerations: []

# Affinity and anti-affinity
affinity: {}
# podAntiAffinity:
#   preferredDuringSchedulingIgnoredDuringExecution:
#   - weight: 100
#     podAffinityTerm:
#       labelSelector:
#         matchExpressions:
#         - key: app
#           operator: In
#           values:
#           - my-app
#       topologyKey: kubernetes.io/hostname

# Environment variables
env:
  - name: NODE_ENV
    value: production
  - name: PORT
    value: "3000"

# Environment from ConfigMaps/Secrets
envFrom:
  - configMapRef:
      name: my-app-config
  - secretRef:
      name: my-app-secrets

# ConfigMap data
configMapData:
  LOG_LEVEL: "info"
  FEATURE_FLAG_X: "true"

# Secret data (use external secret management in production!)
secretData: {}
# API_KEY: "changeme"
# DATABASE_PASSWORD: "changeme"

# Volumes and volume mounts
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

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 1
  # maxUnavailable: 1

# Dependencies configuration
postgresql:
  enabled: true
  auth:
    database: myapp
    username: myapp
    password: changeme  # Override in production!
  primary:
    persistence:
      enabled: true
      size: 10Gi

redis:
  enabled: true
  auth:
    enabled: false
  master:
    persistence:
      enabled: false
```

## Template Helpers (_helpers.tpl)

Reusable template functions:

```go-template
{{/*
Expand the name of the chart.
*/}}
{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a fully qualified app name.
*/}}
{{- define "my-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "my-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "my-app.labels" -}}
helm.sh/chart: {{ include "my-app.chart" . }}
{{ include "my-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "my-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "my-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "my-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for HPA
*/}}
{{- define "my-app.hpa.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta2" }}
{{- end }}
{{- end }}

{{/*
Image pull policy
*/}}
{{- define "my-app.imagePullPolicy" -}}
{{- if .Values.image.pullPolicy }}
{{- .Values.image.pullPolicy }}
{{- else if eq .Values.image.tag "latest" }}
{{- "Always" }}
{{- else }}
{{- "IfNotPresent" }}
{{- end }}
{{- end }}
```

## Template Examples

### Deployment Template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "my-app.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "my-app.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: {{ .Chart.Name }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ include "my-app.imagePullPolicy" . }}
        ports:
        - name: http
          containerPort: {{ .Values.service.targetPort }}
          protocol: TCP
        {{- with .Values.livenessProbe }}
        livenessProbe:
          {{- toYaml . | nindent 12 }}
        {{- end }}
        {{- with .Values.readinessProbe }}
        readinessProbe:
          {{- toYaml . | nindent 12 }}
        {{- end }}
        {{- with .Values.env }}
        env:
          {{- toYaml . | nindent 12 }}
        {{- end }}
        {{- with .Values.envFrom }}
        envFrom:
          {{- toYaml . | nindent 12 }}
        {{- end }}
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
        {{- with .Values.volumeMounts }}
        volumeMounts:
          {{- toYaml . | nindent 12 }}
        {{- end }}
      {{- with .Values.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

### Ingress Template with Conditionals

```yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "my-app.fullname" $ }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

### ConfigMap Template

```yaml
{{- if .Values.configMapData }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "my-app.fullname" . }}-config
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.configMapData }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
{{- end }}
```

## Templating Functions

### Flow Control

```yaml
# If/else
{{- if .Values.ingress.enabled }}
# Ingress is enabled
{{- else }}
# Ingress is disabled
{{- end }}

# With (scope)
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}

# Range (loop)
{{- range .Values.env }}
- name: {{ .name }}
  value: {{ .value | quote }}
{{- end }}

# Range with index
{{- range $index, $value := .Values.hosts }}
- host{{ $index }}: {{ $value }}
{{- end }}

# Range with key-value
{{- range $key, $value := .Values.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
```

### String Functions

```yaml
# Formatting
{{ .Values.name | upper }}           # UPPERCASE
{{ .Values.name | lower }}           # lowercase
{{ .Values.name | title }}           # Title Case
{{ .Values.name | quote }}           # "quoted"
{{ .Values.name | trunc 63 }}        # Truncate to 63 chars
{{ .Values.name | trimSuffix "-" }}  # Remove trailing -
{{ .Values.name | replace "." "-" }} # Replace . with -
```

### YAML Functions

```yaml
# Convert to YAML
{{- toYaml .Values.resources | nindent 12 }}

# Convert to JSON
{{- toJson .Values.config }}

# Get value or default
{{ .Values.image.tag | default .Chart.AppVersion }}
```

### Include and Template

```yaml
# Include template
{{- include "my-app.labels" . | nindent 4 }}

# Template (rarely used)
{{- template "my-app.name" . }}
```

## Dependency Management

### Adding Dependencies

```yaml
# Chart.yaml
dependencies:
  - name: postgresql
    version: "12.1.9"
    repository: "https://charts.bitnami.com/bitnami"
    condition: postgresql.enabled
  - name: redis
    version: "17.3.7"
    repository: "https://charts.bitnami.com/bitnami"
    condition: redis.enabled
```

### Update Dependencies

```bash
# Download dependencies
helm dependency update my-app/

# List dependencies
helm dependency list my-app/

# Build dependencies
helm dependency build my-app/
```

### Configure Dependencies in values.yaml

```yaml
# values.yaml
postgresql:
  enabled: true
  auth:
    database: myapp
    username: myapp
    password: changeme
  primary:
    persistence:
      enabled: true
      size: 10Gi
      storageClass: fast-ssd

redis:
  enabled: true
  auth:
    enabled: false
  master:
    persistence:
      enabled: false
  replica:
    replicaCount: 2
```

## Multi-Environment Values

### Environment-Specific Values Files

```bash
# values-dev.yaml
replicaCount: 1
image:
  tag: dev
resources:
  requests:
    cpu: 50m
    memory: 64Mi
postgresql:
  enabled: false

# values-staging.yaml
replicaCount: 2
image:
  tag: staging
ingress:
  hosts:
    - host: staging.example.com

# values-prod.yaml
replicaCount: 5
image:
  tag: "1.0.0"
ingress:
  hosts:
    - host: app.example.com
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com
autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 20
```

### Install with Environment Values

```bash
# Development
helm install my-app ./my-app -f values-dev.yaml

# Staging
helm install my-app ./my-app -f values-staging.yaml

# Production
helm install my-app ./my-app -f values-prod.yaml

# Multiple values files (merged left-to-right)
helm install my-app ./my-app \
  -f values.yaml \
  -f values-prod.yaml \
  -f values-secrets.yaml
```

## Helm Commands

### Chart Development

```bash
# Create new chart
helm create my-app

# Lint chart
helm lint my-app/

# Validate templates
helm template my-app my-app/ --debug

# Show computed values
helm template my-app my-app/ --show-only templates/deployment.yaml

# Dry-run install
helm install my-app my-app/ --dry-run --debug
```

### Installation and Upgrades

```bash
# Install release
helm install my-release ./my-app

# Install with namespace creation
helm install my-release ./my-app --namespace my-ns --create-namespace

# Install with values override
helm install my-release ./my-app \
  -f values-prod.yaml \
  --set image.tag=1.2.3 \
  --set replicaCount=5

# Upgrade release
helm upgrade my-release ./my-app

# Upgrade or install (idempotent)
helm upgrade --install my-release ./my-app

# Atomic upgrade (rollback on failure)
helm upgrade my-release ./my-app --atomic --timeout 5m

# Wait for resources to be ready
helm upgrade my-release ./my-app --wait --timeout 10m
```

### Release Management

```bash
# List releases
helm list
helm list --all-namespaces

# Get release status
helm status my-release

# Get release values
helm get values my-release

# Get release manifest
helm get manifest my-release

# Release history
helm history my-release

# Rollback release
helm rollback my-release 1

# Uninstall release
helm uninstall my-release

# Uninstall but keep history
helm uninstall my-release --keep-history
```

### Chart Packaging and Distribution

```bash
# Package chart
helm package my-app/
# Creates my-app-1.0.0.tgz

# Package with specific destination
helm package my-app/ --destination ./dist

# Generate index for chart repository
helm repo index ./dist

# Push to OCI registry
helm push my-app-1.0.0.tgz oci://registry.example.com/charts

# Pull from OCI registry
helm pull oci://registry.example.com/charts/my-app --version 1.0.0

# Install from OCI registry
helm install my-release oci://registry.example.com/charts/my-app --version 1.0.0
```

## Chart Testing

### Test Pods

```yaml
# templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "my-app.fullname" . }}-test-connection"
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  containers:
  - name: wget
    image: busybox
    command: ['wget']
    args: ['{{ include "my-app.fullname" . }}:{{ .Values.service.port }}']
  restartPolicy: Never
```

### Run Tests

```bash
# Run chart tests
helm test my-release

# Run tests with logs
helm test my-release --logs
```

## Best Practices

1. **Version Management**: Use semantic versioning for chart version
2. **Default Values**: Provide sensible defaults in values.yaml
3. **Template Comments**: Add comments explaining complex logic
4. **Required Values**: Use `required` function for mandatory values
5. **Checksums**: Add config checksums to trigger pod restarts on config changes
6. **Conditional Resources**: Use `if` statements for optional resources
7. **Documentation**: Maintain comprehensive README.md
8. **Testing**: Include test pods for validation
9. **Dependencies**: Pin dependency versions, use version ranges carefully
10. **Security**: Never commit secrets, use external secret management

## Common Patterns

### Required Values

```yaml
{{- if not .Values.image.repository }}
{{- fail "image.repository is required" }}
{{- end }}

# Or use required function
image: {{ required "image.repository is required" .Values.image.repository }}
```

### Notes.txt Template

```
1. Get the application URL by running:
{{- if .Values.ingress.enabled }}
{{- range $host := .Values.ingress.hosts }}
  http{{ if $.Values.ingress.tls }}s{{ end }}://{{ $host.host }}
{{- end }}
{{- else if contains "NodePort" .Values.service.type }}
  export NODE_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "my-app.fullname" . }})
  export NODE_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
{{- else if contains "LoadBalancer" .Values.service.type }}
  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
  You can watch the status by running 'kubectl get --namespace {{ .Release.Namespace }} svc -w {{ include "my-app.fullname" . }}'
  export SERVICE_IP=$(kubectl get svc --namespace {{ .Release.Namespace }} {{ include "my-app.fullname" . }} --template "{{"{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}"}}")
  echo http://$SERVICE_IP:{{ .Values.service.port }}
{{- else if contains "ClusterIP" .Values.service.type }}
  export POD_NAME=$(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/name={{ include "my-app.name" . }},app.kubernetes.io/instance={{ .Release.Name }}" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace {{ .Release.Namespace }} port-forward $POD_NAME 8080:{{ .Values.service.targetPort }}
{{- end }}
```
