# Evaluation Scenarios for rr-kubernetes

## Scenario 1: Basic Usage - Create Deployment and Service

**Input:** "Create Kubernetes manifests for deploying a Node.js API with 3 replicas and expose it with a LoadBalancer service"

**Expected Behavior:**

- Automatically activate when "Kubernetes manifests" is mentioned
- Create Deployment manifest with:
  - 3 replicas
  - Proper labels and selectors
  - Container with image and port
  - Resource limits (CPU/memory)
  - Readiness and liveness probes
- Create Service manifest:
  - Type LoadBalancer
  - Selector matching deployment
  - Port mapping
- Use proper YAML structure
- Include namespace (optional but good practice)

**Success Criteria:**

- [ ] Deployment manifest with apiVersion: apps/v1
- [ ] replicas: 3 specified
- [ ] Labels defined (app: api-name)
- [ ] Selector matches labels
- [ ] Container image specified
- [ ] Container port defined
- [ ] Resource requests and limits set
- [ ] Liveness probe configured (httpGet on /health)
- [ ] Readiness probe configured
- [ ] Service manifest with type: LoadBalancer
- [ ] Service selector matches deployment labels
- [ ] Port and targetPort properly mapped

## Scenario 2: Complex Scenario - Production-Ready Application with Security

**Input:** "Deploy a production-ready web application with PostgreSQL backend. Include secrets management, network policies, resource quotas, horizontal pod autoscaling, and proper RBAC. Use persistent volumes for the database."

**Expected Behavior:**

- Load skill and understand production requirements
- Create comprehensive manifest set:
  - Namespace
  - Secret for DB credentials (base64 encoded)
  - ConfigMap for app configuration
  - PersistentVolumeClaim for PostgreSQL
  - PostgreSQL StatefulSet with volume mount
  - PostgreSQL Service (ClusterIP)
  - Web app Deployment with DB connection
  - Web app Service (LoadBalancer)
  - HorizontalPodAutoscaler
  - NetworkPolicy (restrict DB access)
  - ResourceQuota for namespace
  - ServiceAccount
  - Role and RoleBinding
- Reference security best practices
- Include proper labels throughout
- Use ConfigMap and Secrets properly

**Success Criteria:**

- [ ] Namespace created
- [ ] Secret created with DB password (base64)
- [ ] ConfigMap created with non-sensitive config
- [ ] PVC created with appropriate storage class
- [ ] StatefulSet for PostgreSQL with volume mount
- [ ] PostgreSQL Service as ClusterIP (internal only)
- [ ] Deployment references Secret for DB connection
- [ ] Deployment uses ConfigMap for app config
- [ ] HPA configured targeting CPU/memory
- [ ] NetworkPolicy restricts PostgreSQL to app pods only
- [ ] ResourceQuota sets namespace limits
- [ ] ServiceAccount created for app
- [ ] Role with minimal permissions
- [ ] RoleBinding ties ServiceAccount to Role
- [ ] All resources use consistent labels

## Scenario 3: Error Handling - ImagePullBackOff Error

**Input:** "My pods are stuck in ImagePullBackOff status. The image is from a private Docker registry."

**Expected Behavior:**

- Recognize ImagePullBackOff as private registry auth issue
- Check pod events: kubectl describe pod
- Explain private registry requires imagePullSecrets
- Show how to create Docker registry secret
- Add imagePullSecrets to deployment spec
- Verify secret creation
- Provide troubleshooting steps
- Reference Kubernetes security patterns

**Success Criteria:**

- [ ] Identifies ImagePullBackOff as likely auth issue
- [ ] Runs kubectl describe pod to see events
- [ ] Creates Docker registry secret: kubectl create secret docker-registry
- [ ] Shows correct secret syntax with server, username, password
- [ ] Adds imagePullSecrets to pod spec
- [ ] Verifies secret exists: kubectl get secret
- [ ] Suggests checking image name and tag
- [ ] Provides alternative: using a service account with imagePullSecrets
- [ ] Shows how to test: kubectl delete pod (to force recreation)
- [ ] References troubleshooting section
