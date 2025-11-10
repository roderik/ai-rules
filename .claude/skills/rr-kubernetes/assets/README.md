# Kubernetes Template Assets

Production-ready Kubernetes resource templates that can be copied and customized for your applications.

## Templates Included

- **deployment-template.yaml** - Complete production-ready Deployment with security best practices
- **service-examples.yaml** - ClusterIP, NodePort, and LoadBalancer service examples
- **network-policy-examples.yaml** - Common network policy patterns
- **rbac-templates.yaml** - ServiceAccount, Role, and RoleBinding examples
- **openshift-templates.yaml** - OpenShift-specific resources (Route, DeploymentConfig, ImageStream)

## Usage

Copy and customize these templates for your applications:

```bash
# Copy deployment template
cp assets/deployment-template.yaml my-app-deployment.yaml

# Edit with your application details
vim my-app-deployment.yaml

# Validate
kubectl apply -f my-app-deployment.yaml --dry-run=client

# Apply
kubectl apply -f my-app-deployment.yaml
```

## Template Features

All templates follow Kubernetes and security best practices:

- ✅ Run as non-root user
- ✅ Read-only root filesystem
- ✅ Dropped capabilities (ALL)
- ✅ Resource limits and requests
- ✅ Health probes (liveness and readiness)
- ✅ Security contexts (pod and container level)
- ✅ Pod anti-affinity for HA
- ✅ Proper labels following Kubernetes conventions

## Customization Checklist

When using these templates, update:

- [ ] Application name and labels
- [ ] Container image and tag
- [ ] Resource limits and requests
- [ ] Health probe paths and ports
- [ ] Environment variables
- [ ] Namespace
- [ ] Replica count

## See Also

- Use `scripts/generate_manifest.sh` for automated manifest generation
- See `references/k8s-manifests.md` for detailed manifest creation guide
- See `references/security-policies.md` for security best practices
