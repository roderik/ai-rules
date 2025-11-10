# Pulumi Kubernetes Provider Reference

## Overview

Pulumi offers comprehensive Kubernetes provider enabling infrastructure-as-code management across multiple programming languages. Supports direct Kubernetes resource deployment and Helm chart integration.

## Installation

```bash
npm install @pulumi/kubernetes     # TypeScript/Node.js
pip install pulumi-kubernetes      # Python
go get github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes  # Go
```

## Core Resource Management

### Deployments

```typescript
import * as k8s from "@pulumi/kubernetes";

const deployment = new k8s.apps.v1.Deployment("nginx", {
  metadata: {
    name: "nginx-deployment",
    labels: { app: "nginx" },
  },
  spec: {
    replicas: 3,
    selector: {
      matchLabels: { app: "nginx" },
    },
    template: {
      metadata: { labels: { app: "nginx" } },
      spec: {
        containers: [
          {
            name: "nginx",
            image: "nginx:1.21",
            ports: [{ containerPort: 80 }],
            resources: {
              requests: {
                cpu: "100m",
                memory: "128Mi",
              },
              limits: {
                cpu: "500m",
                memory: "512Mi",
              },
            },
            livenessProbe: {
              httpGet: {
                path: "/",
                port: 80,
              },
              initialDelaySeconds: 30,
              periodSeconds: 10,
            },
            readinessProbe: {
              httpGet: {
                path: "/",
                port: 80,
              },
              initialDelaySeconds: 5,
              periodSeconds: 5,
            },
          },
        ],
      },
    },
  },
});

export const deploymentName = deployment.metadata.name;
```

### Services

```typescript
import * as k8s from "@pulumi/kubernetes";

const service = new k8s.core.v1.Service("nginx-service", {
  metadata: {
    name: "nginx-service",
    labels: { app: "nginx" },
  },
  spec: {
    type: "LoadBalancer",
    selector: { app: "nginx" },
    ports: [
      {
        port: 80,
        targetPort: 80,
        protocol: "TCP",
      },
    ],
  },
});

export const serviceIp = service.status.loadBalancer.ingress[0].ip;
```

### ConfigMaps and Secrets

```typescript
import * as k8s from "@pulumi/kubernetes";

const configMap = new k8s.core.v1.ConfigMap("app-config", {
  metadata: {
    name: "app-config",
  },
  data: {
    "app.properties": `
database.url=postgres://db:5432
cache.enabled=true
    `,
    "log.level": "INFO",
  },
});

const secret = new k8s.core.v1.Secret("db-credentials", {
  metadata: {
    name: "db-credentials",
  },
  type: "Opaque",
  stringData: {
    username: "admin",
    password: dbPassword, // From Pulumi config
  },
});

// Use in deployment
const appDeployment = new k8s.apps.v1.Deployment("app", {
  spec: {
    template: {
      spec: {
        containers: [
          {
            name: "app",
            image: "my-app:1.0.0",
            envFrom: [
              {
                configMapRef: {
                  name: configMap.metadata.name,
                },
              },
              {
                secretRef: {
                  name: secret.metadata.name,
                },
              },
            ],
          },
        ],
      },
    },
  },
});
```

### StatefulSets

```typescript
import * as k8s from "@pulumi/kubernetes";

const statefulSet = new k8s.apps.v1.StatefulSet("postgres", {
  metadata: {
    name: "postgres",
  },
  spec: {
    serviceName: "postgres",
    replicas: 3,
    selector: {
      matchLabels: { app: "postgres" },
    },
    template: {
      metadata: { labels: { app: "postgres" } },
      spec: {
        containers: [
          {
            name: "postgres",
            image: "postgres:14",
            ports: [{ containerPort: 5432, name: "postgres" }],
            volumeMounts: [
              {
                name: "data",
                mountPath: "/var/lib/postgresql/data",
              },
            ],
            env: [{ name: "POSTGRES_PASSWORD", value: "changeme" }],
          },
        ],
      },
    },
    volumeClaimTemplates: [
      {
        metadata: { name: "data" },
        spec: {
          accessModes: ["ReadWriteOnce"],
          resources: {
            requests: {
              storage: "10Gi",
            },
          },
        },
      },
    ],
  },
});
```

### Jobs and CronJobs

```typescript
import * as k8s from "@pulumi/kubernetes";

const job = new k8s.batch.v1.Job("backup-job", {
  spec: {
    template: {
      spec: {
        containers: [
          {
            name: "backup",
            image: "backup-tool:latest",
            command: ["/bin/sh", "-c", "backup.sh"],
          },
        ],
        restartPolicy: "OnFailure",
      },
    },
  },
});

const cronJob = new k8s.batch.v1.CronJob("daily-backup", {
  spec: {
    schedule: "0 2 * * *",
    jobTemplate: {
      spec: {
        template: {
          spec: {
            containers: [
              {
                name: "backup",
                image: "backup-tool:latest",
                command: ["/bin/sh", "-c", "backup.sh"],
              },
            ],
            restartPolicy: "OnFailure",
          },
        },
      },
    },
  },
});
```

### Ingress

```typescript
import * as k8s from "@pulumi/kubernetes";

const ingress = new k8s.networking.v1.Ingress("app-ingress", {
  metadata: {
    name: "app-ingress",
    annotations: {
      "kubernetes.io/ingress.class": "nginx",
      "cert-manager.io/cluster-issuer": "letsencrypt-prod",
    },
  },
  spec: {
    tls: [
      {
        hosts: ["app.example.com"],
        secretName: "app-tls",
      },
    ],
    rules: [
      {
        host: "app.example.com",
        http: {
          paths: [
            {
              path: "/",
              pathType: "Prefix",
              backend: {
                service: {
                  name: "app-service",
                  port: { number: 80 },
                },
              },
            },
          ],
        },
      },
    ],
  },
});
```

## Helm Chart Integration

### Deploy from Chart Repository

```typescript
import * as k8s from "@pulumi/kubernetes";

const nginx = new k8s.helm.v3.Chart("nginx", {
  chart: "nginx",
  version: "13.2.0",
  fetchOpts: {
    repo: "https://charts.bitnami.com/bitnami",
  },
  values: {
    replicaCount: 3,
    service: {
      type: "LoadBalancer",
      port: 80,
    },
    ingress: {
      enabled: true,
      hostname: "nginx.example.com",
    },
  },
});
```

### Deploy from Local Chart

```typescript
import * as k8s from "@pulumi/kubernetes";

const myApp = new k8s.helm.v3.Chart("my-app", {
  path: "./charts/my-app",
  values: {
    image: {
      repository: "my-app",
      tag: "1.0.0",
    },
    env: {
      DATABASE_URL: databaseUrl,
    },
  },
});
```

### Chart with Transformations

```typescript
import * as k8s from "@pulumi/kubernetes";

const app = new k8s.helm.v3.Chart(
  "app",
  {
    chart: "app",
    repo: "https://charts.example.com",
  },
  {
    transformations: [
      (obj: any) => {
        // Add labels to all resources
        if (obj.metadata) {
          obj.metadata.labels = {
            ...obj.metadata.labels,
            managedBy: "pulumi",
            environment: "production",
          };
        }
      },
    ],
  },
);
```

## Provider Configuration

### Multiple Kubernetes Clusters

```typescript
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

// Default provider (uses current context)
const devProvider = new k8s.Provider("dev", {
  kubeconfig: devKubeconfig,
  context: "dev-cluster",
});

const prodProvider = new k8s.Provider("prod", {
  kubeconfig: prodKubeconfig,
  context: "prod-cluster",
});

// Deploy to dev cluster
const devDeployment = new k8s.apps.v1.Deployment(
  "app-dev",
  {
    spec: {
      replicas: 1,
      // ... spec
    },
  },
  { provider: devProvider },
);

// Deploy to prod cluster
const prodDeployment = new k8s.apps.v1.Deployment(
  "app-prod",
  {
    spec: {
      replicas: 3,
      // ... spec
    },
  },
  { provider: prodProvider },
);
```

### Server-Side Apply

```typescript
import * as k8s from "@pulumi/kubernetes";

const provider = new k8s.Provider("k8s", {
  enableServerSideApply: true,
});

const deployment = new k8s.apps.v1.Deployment(
  "app",
  {
    spec: {
      // ... spec
    },
  },
  { provider },
);
```

## RBAC Configuration

```typescript
import * as k8s from "@pulumi/kubernetes";

const serviceAccount = new k8s.core.v1.ServiceAccount("app-sa", {
  metadata: {
    name: "app-service-account",
  },
});

const role = new k8s.rbac.v1.Role("app-role", {
  metadata: {
    name: "app-role",
  },
  rules: [
    {
      apiGroups: [""],
      resources: ["configmaps", "secrets"],
      verbs: ["get", "list", "watch"],
    },
    {
      apiGroups: ["apps"],
      resources: ["deployments"],
      verbs: ["get", "list"],
    },
  ],
});

const roleBinding = new k8s.rbac.v1.RoleBinding("app-role-binding", {
  metadata: {
    name: "app-role-binding",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: serviceAccount.metadata.name,
    },
  ],
  roleRef: {
    kind: "Role",
    name: role.metadata.name,
    apiGroup: "rbac.authorization.k8s.io",
  },
});

// Use service account in deployment
const deployment = new k8s.apps.v1.Deployment("app", {
  spec: {
    template: {
      spec: {
        serviceAccountName: serviceAccount.metadata.name,
        containers: [
          {
            name: "app",
            image: "my-app:1.0.0",
          },
        ],
      },
    },
  },
});
```

## Namespace Management

```typescript
import * as k8s from "@pulumi/kubernetes";

const namespace = new k8s.core.v1.Namespace("production", {
  metadata: {
    name: "production",
    labels: {
      environment: "production",
    },
  },
});

// Deploy resources to namespace
const deployment = new k8s.apps.v1.Deployment("app", {
  metadata: {
    namespace: namespace.metadata.name,
    name: "app",
  },
  spec: {
    // ... spec
  },
});
```

## Custom Resource Definitions (CRDs)

```typescript
import * as k8s from "@pulumi/kubernetes";

const crd = new k8s.apiextensions.v1.CustomResourceDefinition("mycrd", {
  metadata: {
    name: "myresources.example.com",
  },
  spec: {
    group: "example.com",
    names: {
      kind: "MyResource",
      plural: "myresources",
      singular: "myresource",
    },
    scope: "Namespaced",
    versions: [
      {
        name: "v1",
        served: true,
        storage: true,
        schema: {
          openAPIV3Schema: {
            type: "object",
            properties: {
              spec: {
                type: "object",
                properties: {
                  replicas: { type: "integer" },
                },
              },
            },
          },
        },
      },
    ],
  },
});

// Use the CRD
const customResource = new k8s.apiextensions.CustomResource(
  "my-instance",
  {
    apiVersion: "example.com/v1",
    kind: "MyResource",
    metadata: {
      name: "my-instance",
    },
    spec: {
      replicas: 3,
    },
  },
  { dependsOn: [crd] },
);
```

## Best Practices

### Resource Management

1. **Namespaces**: Organize resources into logical namespaces
2. **Labels**: Consistent labeling for selection and organization
3. **Resource limits**: Always set requests and limits
4. **Health probes**: Implement liveness and readiness probes
5. **Graceful shutdown**: Configure proper termination grace periods

### Security

1. **RBAC**: Implement least privilege access control
2. **Network policies**: Restrict pod-to-pod communication
3. **Pod security**: Run as non-root, read-only filesystem
4. **Secrets**: Use external secret management (Sealed Secrets, Vault)
5. **Image security**: Use trusted registries, scan images

### Reliability

1. **Multiple replicas**: Run multiple instances for high availability
2. **Pod disruption budgets**: Ensure minimum availability during updates
3. **Anti-affinity**: Spread pods across nodes/zones
4. **Rolling updates**: Configure update strategy
5. **Monitoring**: Set up metrics and logging

### Operations

1. **GitOps**: Store manifests in version control
2. **CI/CD**: Automate testing and deployment
3. **Observability**: Use logging, metrics, tracing
4. **Documentation**: Document architecture and dependencies
5. **Testing**: Test in staging before production

## Common Patterns

### Blue-Green Deployment

```typescript
import * as k8s from "@pulumi/kubernetes";

const blueDeployment = new k8s.apps.v1.Deployment("app-blue", {
  spec: {
    replicas: 3,
    selector: { matchLabels: { app: "myapp", version: "blue" } },
    template: {
      metadata: { labels: { app: "myapp", version: "blue" } },
      spec: {
        containers: [{ name: "app", image: "myapp:1.0.0" }],
      },
    },
  },
});

const greenDeployment = new k8s.apps.v1.Deployment("app-green", {
  spec: {
    replicas: 3,
    selector: { matchLabels: { app: "myapp", version: "green" } },
    template: {
      metadata: { labels: { app: "myapp", version: "green" } },
      spec: {
        containers: [{ name: "app", image: "myapp:2.0.0" }],
      },
    },
  },
});

// Switch traffic by updating service selector
const service = new k8s.core.v1.Service("app-service", {
  spec: {
    selector: { app: "myapp", version: "green" }, // Switch to green
    ports: [{ port: 80, targetPort: 8080 }],
  },
});
```

### Sidecar Pattern

```typescript
import * as k8s from "@pulumi/kubernetes";

const deployment = new k8s.apps.v1.Deployment("app-with-sidecar", {
  spec: {
    template: {
      spec: {
        containers: [
          {
            name: "app",
            image: "my-app:1.0.0",
            ports: [{ containerPort: 8080 }],
          },
          {
            name: "log-collector",
            image: "fluent-bit:latest",
            volumeMounts: [
              {
                name: "logs",
                mountPath: "/var/log/app",
              },
            ],
          },
        ],
        volumes: [
          {
            name: "logs",
            emptyDir: {},
          },
        ],
      },
    },
  },
});
```

## Troubleshooting

### Common Issues

1. **ImagePullBackOff**: Check image name, tag, and registry credentials
2. **CrashLoopBackOff**: Check logs with `kubectl logs`, review health probes
3. **Pending pods**: Check resource requests, node capacity, affinity rules
4. **Service unreachable**: Verify selector labels match pod labels
5. **Permission errors**: Review RBAC configuration

### Debug Commands

```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```
