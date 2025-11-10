# OpenShift-Specific Resources and Patterns

OpenShift extends Kubernetes with additional enterprise features, developer tools, and specialized resources.

## Key Differences from Vanilla Kubernetes

1. **CLI Tool**: `oc` instead of (or in addition to) `kubectl`
2. **Projects**: Higher-level abstraction over namespaces
3. **Routes**: Native ingress alternative with integrated load balancing
4. **ImageStreams**: Abstract layer for managing container images
5. **BuildConfigs**: Native CI/CD with source-to-image builds
6. **DeploymentConfigs**: Extended deployment strategy options
7. **Security Context Constraints (SCC)**: More restrictive than PSP
8. **Integrated Registry**: Built-in container registry
9. **Web Console**: Full-featured graphical interface
10. **Operators**: Extensive operator ecosystem

## Routes (OpenShift's Ingress)

Routes provide external access to services with built-in load balancing and TLS termination.

### Basic HTTP Route

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app
  namespace: production
  labels:
    app: my-app
spec:
  host: my-app.apps.cluster.example.com
  to:
    kind: Service
    name: my-app
    weight: 100
  port:
    targetPort: http
  wildcardPolicy: None
```

### HTTPS Route with Edge Termination

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app-secure
  namespace: production
spec:
  host: my-app.apps.cluster.example.com
  to:
    kind: Service
    name: my-app
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
    certificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
    caCertificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

### Re-encryption Route

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app-reencrypt
spec:
  host: my-app.apps.cluster.example.com
  to:
    kind: Service
    name: my-app
  tls:
    termination: reencrypt
    destinationCACertificate: |
      -----BEGIN CERTIFICATE-----
      ...
      -----END CERTIFICATE-----
```

### Passthrough Route

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app-passthrough
spec:
  host: my-app.apps.cluster.example.com
  to:
    kind: Service
    name: my-app
  tls:
    termination: passthrough
```

### Blue-Green Route (Traffic Splitting)

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app-canary
spec:
  host: my-app.apps.cluster.example.com
  to:
    kind: Service
    name: my-app-blue
    weight: 90
  alternateBackends:
  - kind: Service
    name: my-app-green
    weight: 10
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

## ImageStreams

Manage and abstract container images.

### ImageStream

```yaml
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: my-app
  namespace: production
spec:
  lookupPolicy:
    local: true  # Allow referencing without full path
  tags:
  - name: latest
    from:
      kind: DockerImage
      name: quay.io/myorg/my-app:latest
    importPolicy:
      scheduled: true  # Auto-update from external registry
    referencePolicy:
      type: Local
```

### Reference ImageStream in Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      containers:
      - name: my-app
        # Reference ImageStream instead of external registry
        image: image-registry.openshift-image-registry.svc:5000/production/my-app:latest
```

## BuildConfigs

Native build automation with source-to-image, Docker, and custom strategies.

### Docker Build Strategy

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: my-app
  namespace: production
spec:
  source:
    type: Git
    git:
      uri: https://github.com/example/my-app
      ref: main
    contextDir: /
  strategy:
    type: Docker
    dockerStrategy:
      dockerfilePath: Dockerfile
      env:
      - name: NODE_ENV
        value: production
  output:
    to:
      kind: ImageStreamTag
      name: my-app:latest
  triggers:
  - type: ConfigChange
  - type: GitHub
    github:
      secret: github-webhook-secret
  - type: Generic
    generic:
      secret: generic-webhook-secret
```

### Source-to-Image (S2I) Strategy

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: my-nodejs-app
spec:
  source:
    type: Git
    git:
      uri: https://github.com/example/my-app
      ref: main
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        name: nodejs:16
        namespace: openshift
      env:
      - name: NPM_MIRROR
        value: https://registry.npmjs.org
  output:
    to:
      kind: ImageStreamTag
      name: my-nodejs-app:latest
```

### Binary Build

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: my-app-binary
spec:
  source:
    type: Binary
  strategy:
    type: Docker
  output:
    to:
      kind: ImageStreamTag
      name: my-app:latest
```

```bash
# Start binary build
oc start-build my-app-binary --from-dir=. --follow
```

## DeploymentConfigs

OpenShift-specific deployment with additional strategies.

### Basic DeploymentConfig

```yaml
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: my-app
  namespace: production
spec:
  replicas: 3
  selector:
    app: my-app
  strategy:
    type: Rolling
    rollingParams:
      updatePeriodSeconds: 1
      intervalSeconds: 1
      timeoutSeconds: 600
      maxSurge: 25%
      maxUnavailable: 25%
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: image-registry.openshift-image-registry.svc:5000/production/my-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: production
  triggers:
  - type: ConfigChange
  - type: ImageChange
    imageChangeParams:
      automatic: true
      containerNames:
      - my-app
      from:
        kind: ImageStreamTag
        name: my-app:latest
        namespace: production
```

### Recreate Strategy

```yaml
spec:
  strategy:
    type: Recreate
    recreateParams:
      pre:
        failurePolicy: Abort
        execNewPod:
          containerName: my-app
          command:
          - /bin/sh
          - -c
          - echo "Pre-deployment hook"
      post:
        failurePolicy: Ignore
        execNewPod:
          containerName: my-app
          command:
          - /bin/sh
          - -c
          - echo "Post-deployment hook"
```

### Custom Deployment Strategy

```yaml
spec:
  strategy:
    type: Custom
    customParams:
      image: myorg/custom-deployer:latest
      command:
      - /bin/custom-deploy.sh
      environment:
      - name: DEPLOYMENT_NAME
        value: my-app
```

## Security Context Constraints (SCC)

More restrictive than Kubernetes Pod Security Policies.

### View SCCs

```bash
# List all SCCs
oc get scc

# Describe SCC
oc describe scc restricted

# Check which SCC is assigned to ServiceAccount
oc get pod my-pod -o yaml | grep openshift.io/scc
```

### Custom SCC

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: my-app-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
defaultAddCapabilities: []
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1000
    max: 2000
readOnlyRootFilesystem: true
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsRange
  uidRangeMin: 1000
  uidRangeMax: 2000
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
users:
- system:serviceaccount:production:my-app
```

### Grant SCC to ServiceAccount

```bash
oc adm policy add-scc-to-user my-app-scc -z my-app -n production
```

## Projects (Namespaces)

Projects are namespaces with additional annotations and network isolation.

### Create Project

```bash
# Via oc
oc new-project my-project --display-name="My Project" --description="Project for my app"

# Or via YAML
apiVersion: project.openshift.io/v1
kind: Project
metadata:
  name: my-project
  annotations:
    openshift.io/display-name: "My Project"
    openshift.io/description: "Project for my app"
    openshift.io/requester: "developer@example.com"
```

### Project Network Isolation

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: isolated-project
  annotations:
    # Isolate project network
    netnamespace.network.openshift.io/policy-name: isolated
```

## Templates

Parameterized resource definitions for easy instantiation.

### Template Definition

```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: my-app-template
  namespace: openshift
  annotations:
    description: "My application template"
    tags: "nodejs,microservice"
    iconClass: "icon-nodejs"
objects:
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ${APP_NAME}
  spec:
    replicas: ${{REPLICAS}}
    selector:
      matchLabels:
        app: ${APP_NAME}
    template:
      metadata:
        labels:
          app: ${APP_NAME}
      spec:
        containers:
        - name: ${APP_NAME}
          image: ${IMAGE}:${IMAGE_TAG}
          ports:
          - containerPort: ${{PORT}}
          env:
          - name: NODE_ENV
            value: ${NODE_ENV}
- apiVersion: v1
  kind: Service
  metadata:
    name: ${APP_NAME}
  spec:
    selector:
      app: ${APP_NAME}
    ports:
    - port: 80
      targetPort: ${{PORT}}
- apiVersion: route.openshift.io/v1
  kind: Route
  metadata:
    name: ${APP_NAME}
  spec:
    to:
      kind: Service
      name: ${APP_NAME}
    tls:
      termination: edge
parameters:
- name: APP_NAME
  description: "Application name"
  required: true
- name: IMAGE
  description: "Container image"
  value: "my-app"
- name: IMAGE_TAG
  description: "Image tag"
  value: "latest"
- name: REPLICAS
  description: "Number of replicas"
  value: "3"
- name: PORT
  description: "Application port"
  value: "3000"
- name: NODE_ENV
  description: "Node environment"
  value: "production"
```

### Process Template

```bash
# Process and apply
oc process my-app-template \
  -p APP_NAME=my-app \
  -p IMAGE_TAG=1.0.0 \
  -p REPLICAS=5 | oc apply -f -

# Process to file
oc process my-app-template -p APP_NAME=my-app -o yaml > manifests.yaml
```

## OpenShift CLI (oc) Commands

### Project Management

```bash
# Create project
oc new-project my-project

# Switch project
oc project my-project

# List projects
oc projects

# Delete project
oc delete project my-project

# Grant access to project
oc policy add-role-to-user edit developer -n my-project
```

### Application Management

```bash
# Create app from Git
oc new-app https://github.com/example/my-app

# Create app from image
oc new-app nodejs:16~https://github.com/example/my-app

# Create app from template
oc new-app -f template.yaml

# List all resources
oc get all

# Delete app and all resources
oc delete all -l app=my-app
```

### Build Management

```bash
# Start build
oc start-build my-app

# Start build from local directory
oc start-build my-app --from-dir=. --follow

# Follow build logs
oc logs -f bc/my-app

# Cancel build
oc cancel-build my-app-1

# List builds
oc get builds
```

### Route Management

```bash
# Expose service via route
oc expose svc/my-app

# Create secure route
oc create route edge my-app --service=my-app --cert=tls.crt --key=tls.key

# Get route URL
oc get route my-app -o jsonpath='{.spec.host}'

# Delete route
oc delete route my-app
```

### ImageStream Management

```bash
# Import image
oc import-image my-app:latest --from=quay.io/myorg/my-app:latest --confirm

# Tag image
oc tag my-app:latest my-app:stable

# List image streams
oc get imagestreams

# Get image SHA
oc get is my-app -o jsonpath='{.status.tags[?(@.tag=="latest")].items[0].dockerImageReference}'
```

### Deployment Management

```bash
# Rollout latest
oc rollout latest dc/my-app

# Rollout status
oc rollout status dc/my-app

# Rollout history
oc rollout history dc/my-app

# Rollback
oc rollout undo dc/my-app

# Cancel rollout
oc rollout cancel dc/my-app

# Scale
oc scale dc/my-app --replicas=5
```

### Debugging

```bash
# Remote shell
oc rsh my-app-pod

# Port forward
oc port-forward my-app-pod 8080:3000

# Copy files
oc cp my-app-pod:/app/logs/app.log ./app.log

# Debug pod
oc debug dc/my-app

# Run command
oc exec my-app-pod -- ps aux
```

### User and Access Management

```bash
# Login
oc login https://api.cluster.example.com:6443

# Get current user
oc whoami

# Get user token
oc whoami -t

# Add role to user
oc adm policy add-role-to-user admin developer -n my-project

# Add cluster role
oc adm policy add-cluster-role-to-user cluster-admin admin

# View cluster role bindings
oc get clusterrolebinding
```

## Service Mesh (Istio on OpenShift)

OpenShift Service Mesh based on Istio.

### Install Service Mesh

```bash
# Install operators
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

### ServiceMeshControlPlane

```yaml
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: basic
  namespace: istio-system
spec:
  version: v2.3
  tracing:
    type: Jaeger
  addons:
    grafana:
      enabled: true
    jaeger:
      install:
        storage:
          type: Memory
    kiali:
      enabled: true
    prometheus:
      enabled: true
```

### ServiceMeshMemberRoll

```yaml
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: istio-system
spec:
  members:
  - production
  - staging
```

## Serverless (Knative on OpenShift)

### Install OpenShift Serverless

```bash
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: serverless-operator
  namespace: openshift-serverless
spec:
  channel: stable
  name: serverless-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

### Knative Service

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-app
  namespace: production
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/min-scale: "1"
        autoscaling.knative.dev/max-scale: "10"
    spec:
      containers:
      - image: quay.io/myorg/my-app:latest
        ports:
        - containerPort: 8080
        env:
        - name: TARGET
          value: "World"
```

## Best Practices

### Use Standard Kubernetes Resources When Possible

Prefer Deployments over DeploymentConfigs for portability:
```bash
# Migrate DC to Deployment
oc get dc my-app -o yaml > dc.yaml
# Convert manually to Deployment
oc apply -f deployment.yaml
oc delete dc my-app
```

### Image Management

```bash
# Always use specific tags
oc tag my-app:1.0.0 my-app:production

# Regular cleanup
oc adm prune images --confirm
```

### Resource Limits

```yaml
# Always set limits in DeploymentConfig/Deployment
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Health Checks

```yaml
# Add probes to DeploymentConfig
livenessProbe:
  httpGet:
    path: /health
    port: 3000
readinessProbe:
  httpGet:
    path: /ready
    port: 3000
```

## Common Patterns

### CI/CD Pipeline

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: build-and-deploy
spec:
  params:
  - name: APP_NAME
  - name: GIT_URL
  - name: IMAGE_NAME
  tasks:
  - name: fetch-repository
    taskRef:
      name: git-clone
  - name: build-image
    taskRef:
      name: buildah
  - name: deploy
    taskRef:
      name: openshift-client
```

### Blue-Green Deployment

```bash
# Deploy green
oc new-app my-app:2.0.0 --name=my-app-green

# Test green
oc expose svc/my-app-green --name=my-app-green-test

# Switch route
oc patch route my-app -p '{"spec":{"to":{"name":"my-app-green"}}}'

# Remove blue when confident
oc delete all -l app=my-app-blue
```
