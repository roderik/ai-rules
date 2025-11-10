---
name: rr-pulumi
description: Comprehensive Pulumi infrastructure-as-code skill for AWS, Kubernetes, and multi-cloud deployments. Use for defining cloud infrastructure using TypeScript, Python, Go, or other languages. Covers projects, stacks, resources, configuration, state management, Automation API, and CI/CD integration. Automatically triggered when working with Pulumi projects or infrastructure-as-code tasks.
---

# Pulumi Infrastructure as Code

## Overview

Professional infrastructure-as-code skill using Pulumi for AWS, Kubernetes, and multi-cloud deployments. Define cloud infrastructure using general-purpose programming languages (TypeScript, Python, Go, C#, Java, YAML) rather than domain-specific configuration formats. Access 120+ cloud providers with type-safe interfaces and automatic dependency resolution.

## When to Use This Skill

Automatically activate when:

- Working with Pulumi project files (`Pulumi.yaml`, `Pulumi.<stack>.yaml`)
- User mentions Pulumi, infrastructure-as-code, or IaC
- Deploying AWS, Kubernetes, or multi-cloud infrastructure
- Using `.ts`, `.py`, `.go` files with Pulumi imports
- User requests infrastructure automation, stack management, or resource provisioning
- Working with `pulumi` CLI commands or Automation API
- Implementing GitOps workflows or CI/CD infrastructure deployments

## Core Workflows

### 1. Project Initialization and Setup

**Create new project from template:**

```bash
pulumi new aws-typescript        # AWS with TypeScript
pulumi new kubernetes-python     # Kubernetes with Python
pulumi new azure-go             # Azure with Go
```

**Project structure:**

```
my-infra/
├── Pulumi.yaml              # Project metadata
├── Pulumi.dev.yaml          # Dev stack configuration
├── Pulumi.prod.yaml         # Production stack configuration
├── index.ts                 # Infrastructure code
└── package.json             # Dependencies (for TypeScript)
```

**Initialize stack:**

```bash
pulumi stack init dev           # Create dev stack
pulumi stack init prod          # Create prod stack
pulumi stack select dev         # Switch to dev stack
```

### 2. Resource Definition Patterns

**Basic resource creation (TypeScript):**

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// S3 bucket with encryption
const bucket = new aws.s3.Bucket("my-bucket", {
  acl: "private",
  serverSideEncryptionConfiguration: {
    rule: {
      applyServerSideEncryptionByDefault: {
        sseAlgorithm: "AES256",
      },
    },
  },
  tags: {
    Environment: "production",
    ManagedBy: "pulumi",
  },
});

// Export bucket name for reference
export const bucketName = bucket.id;
```

**Lambda function with inline code:**

```typescript
import * as aws from "@pulumi/aws";

// Lambda function from inline code
const lambda = new aws.lambda.CallbackFunction("my-function", {
  callback: async (event: any) => {
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Hello from Pulumi!" }),
    };
  },
  runtime: aws.lambda.Runtime.NodeJS18dX,
  environment: {
    variables: {
      ENV: "production",
    },
  },
});

export const lambdaArn = lambda.arn;
```

**Kubernetes deployment:**

```typescript
import * as k8s from "@pulumi/kubernetes";

const deployment = new k8s.apps.v1.Deployment("nginx", {
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
          },
        ],
      },
    },
  },
});
```

### 3. Component Resources (Reusable Abstractions)

**Create custom component:**

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

interface WebServiceArgs {
  instanceType: pulumi.Input<string>;
  desiredCapacity: pulumi.Input<number>;
}

class WebService extends pulumi.ComponentResource {
  public readonly loadBalancerUrl: pulumi.Output<string>;

  constructor(
    name: string,
    args: WebServiceArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("custom:service:WebService", name, {}, opts);

    // Security group
    const sg = new aws.ec2.SecurityGroup(
      `${name}-sg`,
      {
        ingress: [
          {
            protocol: "tcp",
            fromPort: 80,
            toPort: 80,
            cidrBlocks: ["0.0.0.0/0"],
          },
        ],
        egress: [
          { protocol: "-1", fromPort: 0, toPort: 0, cidrBlocks: ["0.0.0.0/0"] },
        ],
      },
      { parent: this },
    );

    // Load balancer
    const lb = new aws.lb.LoadBalancer(
      `${name}-lb`,
      {
        internal: false,
        loadBalancerType: "application",
        securityGroups: [sg.id],
      },
      { parent: this },
    );

    this.loadBalancerUrl = lb.dnsName;
    this.registerOutputs({
      loadBalancerUrl: this.loadBalancerUrl,
    });
  }
}

// Use the component
const webService = new WebService("my-web-service", {
  instanceType: "t3.micro",
  desiredCapacity: 2,
});

export const url = webService.loadBalancerUrl;
```

### 4. Configuration and Secrets

**Set configuration:**

```bash
pulumi config set aws:region us-west-2
pulumi config set instanceCount 3
pulumi config set --secret dbPassword mySecretPassword123
```

**Read configuration in code:**

```typescript
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();
const region = config.get("region") || "us-east-1";
const instanceCount = config.getNumber("instanceCount") || 1;
const dbPassword = config.requireSecret("dbPassword"); // Encrypted

// Use configuration
const instances: aws.ec2.Instance[] = [];
for (let i = 0; i < instanceCount; i++) {
  instances.push(
    new aws.ec2.Instance(`instance-${i}`, {
      instanceType: "t3.micro",
      ami: "ami-0c55b159cbfafe1f0",
    }),
  );
}
```

**Configuration files:**

```yaml
# Pulumi.dev.yaml
config:
  aws:region: us-west-2
  my-app:instanceCount: "1"
  my-app:dbPassword:
    secure: AAABAdzDefGhi... # Encrypted
```

### 5. Stack References (Cross-Stack Dependencies)

**Export outputs from networking stack:**

```typescript
// networking/index.ts
import * as aws from "@pulumi/aws";

const vpc = new aws.ec2.Vpc("main", {
  cidrBlock: "10.0.0.0/16",
});

export const vpcId = vpc.id;
export const publicSubnetIds = publicSubnets.map((s) => s.id);
```

**Reference outputs in application stack:**

```typescript
// application/index.ts
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Reference networking stack
const networkStack = new pulumi.StackReference("myOrg/networking/prod");
const vpcId = networkStack.getOutput("vpcId");
const subnetIds = networkStack.getOutput("publicSubnetIds");

// Use referenced outputs
const instance = new aws.ec2.Instance("app-instance", {
  vpcSecurityGroupIds: [sg.id],
  subnetId: subnetIds[0],
  instanceType: "t3.micro",
  ami: "ami-0c55b159cbfafe1f0",
});
```

### 6. Automation API (Embedded Infrastructure)

**Inline program with Automation API:**

```typescript
import * as pulumi from "@pulumi/pulumi/automation";
import * as aws from "@pulumi/aws";

const stackName = "dev";
const projectName = "my-app";

// Define infrastructure as code
const program = async () => {
  const bucket = new aws.s3.Bucket("my-bucket", {
    acl: "private",
  });

  return {
    bucketName: bucket.id,
  };
};

// Create or select stack
const stack = await pulumi.LocalWorkspace.createOrSelectStack({
  stackName,
  projectName,
  program,
});

// Configure stack
await stack.setConfig("aws:region", { value: "us-west-2" });

// Deploy
const upResult = await stack.up({ onOutput: console.log });
console.log(`Bucket: ${upResult.outputs.bucketName.value}`);
```

**GitOps workflow with remote source:**

```typescript
import * as pulumi from "@pulumi/pulumi/automation";

const stack = await pulumi.LocalWorkspace.createOrSelectStack({
  stackName: "prod",
  projectName: "my-app",
  url: "https://github.com/myorg/infrastructure.git",
  branch: "main",
  auth: {
    personalAccessToken: process.env.GITHUB_TOKEN,
  },
});

// Preview changes
const previewResult = await stack.preview();
console.log(
  `Changes: ${previewResult.changeSummary.create} create, ${previewResult.changeSummary.update} update`,
);

// Deploy with approval
if (await getApproval()) {
  await stack.up({ onOutput: console.log });
}
```

### 7. Multi-Provider and Multi-Region

**Multiple AWS regions:**

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Default region provider
const usWest = new aws.Provider("us-west", {
  region: "us-west-2",
});

// Additional region provider
const usEast = new aws.Provider("us-east", {
  region: "us-east-1",
});

// Resources in different regions
const westBucket = new aws.s3.Bucket(
  "west-bucket",
  {
    acl: "private",
  },
  { provider: usWest },
);

const eastBucket = new aws.s3.Bucket(
  "east-bucket",
  {
    acl: "private",
  },
  { provider: usEast },
);
```

**Hybrid AWS + Kubernetes:**

```typescript
import * as aws from "@pulumi/aws";
import * as k8s from "@pulumi/kubernetes";

// Create EKS cluster
const cluster = new aws.eks.Cluster("my-cluster", {
  vpcId: vpc.id,
  subnetIds: subnets.map((s) => s.id),
});

// Configure Kubernetes provider
const k8sProvider = new k8s.Provider("k8s", {
  kubeconfig: cluster.kubeconfig,
});

// Deploy to EKS
const deployment = new k8s.apps.v1.Deployment(
  "app",
  {
    spec: {
      replicas: 3,
      selector: { matchLabels: { app: "my-app" } },
      template: {
        metadata: { labels: { app: "my-app" } },
        spec: {
          containers: [
            {
              name: "app",
              image: "my-app:1.0.0",
            },
          ],
        },
      },
    },
  },
  { provider: k8sProvider },
);
```

## Essential CLI Commands

```bash
# Project and stack management
pulumi new [template]           # Create new project
pulumi stack init [name]        # Create new stack
pulumi stack select [name]      # Switch active stack
pulumi stack ls                 # List all stacks
pulumi stack rm [name]          # Delete stack
pulumi stack output [name]      # Get stack output

# Configuration
pulumi config set [key] [value]         # Set configuration
pulumi config set --secret [key] [val]  # Set encrypted secret
pulumi config get [key]                 # Get configuration value
pulumi config                           # List all configuration

# Deployment
pulumi preview                  # Preview changes
pulumi up                      # Deploy infrastructure
pulumi up --yes                # Deploy without confirmation
pulumi destroy                 # Destroy all resources
pulumi destroy --yes           # Destroy without confirmation
pulumi refresh                 # Sync state with cloud
pulumi cancel                  # Cancel in-progress operation

# State management
pulumi stack export > state.json      # Export state
pulumi stack import < state.json      # Import state
pulumi state delete [urn]            # Remove resource from state

# Stack references
pulumi stack output vpcId           # Get output from current stack
pulumi stack output --show-secrets  # Show secret outputs

# Plugin management
pulumi plugin ls                    # List installed plugins
pulumi plugin install resource aws  # Install AWS provider
```

## CI/CD Integration Patterns

**GitHub Actions workflow:**

```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: pulumi/actions@v4
        with:
          command: up
          stack-name: prod
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

**Preview on pull request:**

```yaml
name: Preview Changes
on:
  pull_request:
    branches: [main]

jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: pulumi/actions@v4
        with:
          command: preview
          stack-name: prod
          comment-on-pr: true
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Testing Infrastructure

**Automated testing with Automation API:**

```typescript
import { describe, it, expect, afterEach } from "bun:test";
import * as pulumi from "@pulumi/pulumi/automation";

describe("Infrastructure Tests", () => {
  let stack: pulumi.Stack;

  afterEach(async () => {
    if (stack) {
      await stack.destroy();
      await stack.workspace.removeStack(stack.name);
    }
  });

  it("should create S3 bucket with encryption", async () => {
    stack = await pulumi.LocalWorkspace.createOrSelectStack({
      stackName: `test-${Date.now()}`,
      projectName: "test-project",
      program: async () => {
        const bucket = new aws.s3.Bucket("test-bucket", {
          serverSideEncryptionConfiguration: {
            rule: {
              applyServerSideEncryptionByDefault: {
                sseAlgorithm: "AES256",
              },
            },
          },
        });

        return { bucketName: bucket.id };
      },
    });

    const upResult = await stack.up();

    expect(upResult.summary.result).toBe("succeeded");
    expect(upResult.outputs.bucketName).toBeDefined();
  });
});
```

## Best Practices

### Security

1. **Encrypt secrets**: Always use `pulumi config set --secret` for sensitive values
2. **Least privilege IAM**: Grant minimal necessary permissions to resources
3. **Private resources**: Default to private access, explicit public exposure
4. **Network segmentation**: Use VPCs, security groups, and network policies
5. **Secrets management**: Consider external secret stores (AWS Secrets Manager, Vault)

### State Management

1. **Remote backend**: Use Pulumi Cloud or S3 backend for team collaboration
2. **State versioning**: Enable versioning on S3 backend buckets
3. **State encryption**: Encrypt state at rest with KMS or cloud provider encryption
4. **Regular exports**: Backup state with `pulumi stack export`
5. **Stack isolation**: Use separate stacks for environments (dev/staging/prod)

### Code Organization

1. **Component resources**: Encapsulate related resources into reusable components
2. **Stack references**: Separate networking, data, and application stacks
3. **Configuration files**: Use `Pulumi.<stack>.yaml` for environment-specific config
4. **Type safety**: Leverage TypeScript for compile-time validation
5. **Version control**: Store Pulumi projects in Git with clear branching strategies

### Resource Management

1. **Explicit names**: Use meaningful resource names for identification
2. **Tagging**: Apply consistent tags for cost tracking and organization
3. **Resource limits**: Set appropriate timeouts and limits
4. **Dependencies**: Let Pulumi handle implicit dependencies, use explicit only when needed
5. **Idempotency**: Ensure operations can be safely retried

### Operations

1. **Preview first**: Always run `pulumi preview` before `pulumi up`
2. **Small changes**: Deploy incremental changes rather than large updates
3. **Rollback plan**: Test destroy and recreation procedures
4. **Monitor deployments**: Watch logs during deployment operations
5. **Document outputs**: Clearly export relevant values for application consumption

## Common Patterns

### VPC with Public/Private Subnets

See `references/aws-vpc-pattern.md` for complete VPC setup with:

- Public and private subnets across availability zones
- NAT gateways for private subnet internet access
- Route tables and internet gateway configuration
- Security groups with proper ingress/egress rules

### Serverless API with Lambda + API Gateway

See `references/aws-serverless-pattern.md` for:

- API Gateway REST API configuration
- Lambda function with inline code or container images
- IAM roles with least privilege policies
- CloudWatch logging and monitoring

### EKS Cluster with Node Groups

See `references/aws-eks-pattern.md` for:

- EKS cluster with managed node groups
- RBAC configuration and service accounts
- Kubernetes add-ons (CoreDNS, kube-proxy, vpc-cni)
- Application deployment patterns

### Multi-Region Failover

See `references/multi-region-pattern.md` for:

- Cross-region resource replication
- Route53 health checks and failover routing
- DynamoDB global tables or cross-region replication
- Active-active and active-passive architectures

## Resources

### references/

- `aws-vpc-pattern.md` - Complete VPC configuration patterns
- `aws-serverless-pattern.md` - Serverless architecture with Lambda + API Gateway
- `aws-eks-pattern.md` - EKS cluster setup and management
- `multi-region-pattern.md` - Multi-region deployment strategies
- `kubernetes-patterns.md` - Kubernetes resource management with Pulumi
- `pulumi-aws-reference.md` - AWS provider comprehensive reference
- `pulumi-kubernetes-reference.md` - Kubernetes provider comprehensive reference

## Workflow Example

Complete workflow for deploying a production application:

1. **Initialize project**: `pulumi new aws-typescript`
2. **Define resources**: Write infrastructure code in `index.ts`
3. **Configure stack**: Set region, secrets with `pulumi config set`
4. **Preview changes**: `pulumi preview` to review planned operations
5. **Create networking**: Deploy VPC, subnets, security groups first
6. **Export outputs**: Export VPC ID, subnet IDs for application stack
7. **Create application stack**: Reference networking stack outputs
8. **Deploy compute**: Deploy EC2, ECS, or Lambda resources
9. **Test deployment**: Verify resources created correctly
10. **Set up CI/CD**: Automate deployments with GitHub Actions
11. **Monitor**: Set up CloudWatch alarms and logging
12. **Document**: Export outputs, update README with deployment info

## Integration with Development Workflow

**Local development:**

```bash
pulumi stack select dev
pulumi config set instanceCount 1    # Minimal resources for dev
pulumi up
```

**Staging deployment:**

```bash
pulumi stack select staging
pulumi config set instanceCount 2
pulumi up
```

**Production deployment:**

```bash
pulumi stack select prod
pulumi config set instanceCount 5
pulumi preview  # Review changes
pulumi up --yes  # Deploy after approval
```

## Troubleshooting

**Common issues:**

1. **Resource already exists**: Use `pulumi import` to adopt existing resources
2. **State out of sync**: Run `pulumi refresh` to sync state with cloud
3. **Dependency cycle**: Review resource dependencies, may need explicit `dependsOn`
4. **Permission denied**: Check IAM permissions and provider credentials
5. **Operation timeout**: Increase timeout in resource options or check resource health

**Debug commands:**

```bash
pulumi stack --show-urns          # Show resource URNs
pulumi state delete [urn]         # Remove resource from state
pulumi refresh                    # Sync state with cloud
pulumi stack export > backup.json # Backup state before changes
pulumi logs                       # View deployment logs
```
