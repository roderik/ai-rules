---
name: rr-pulumi
description: Comprehensive Pulumi infrastructure-as-code skill for AWS, Kubernetes, and multi-cloud deployments. Use for defining cloud infrastructure using TypeScript, Python, Go, or other languages. Covers projects, stacks, resources, configuration, state management, Automation API, and CI/CD integration. Also triggers when working with Pulumi files (.ts, .py, .go), Pulumi.yaml, or infrastructure definition files. Example triggers: "Create Pulumi stack", "Define AWS resources", "Set up Kubernetes cluster", "Deploy infrastructure", "Create Pulumi project", "Manage cloud resources", "Update infrastructure"
---

# Pulumi Infrastructure as Code

Define cloud infrastructure using general-purpose programming languages (TypeScript, Python, Go, C#, Java, YAML). Access 120+ cloud providers with type-safe interfaces and automatic dependency resolution.

## When to Use This Skill

Automatically activate when:

- Working with Pulumi project files (`Pulumi.yaml`, `Pulumi.<stack>.yaml`)
- User mentions Pulumi, infrastructure-as-code, or IaC
- Deploying AWS, Kubernetes, or multi-cloud infrastructure
- Using `.ts`, `.py`, `.go` files with Pulumi imports
- User requests infrastructure automation, stack management, or resource provisioning
- Working with `pulumi` CLI commands or Automation API
- Implementing GitOps workflows or CI/CD infrastructure deployments

## Development Workflow

### 1. Plan Infrastructure

**Before writing code:**

- [ ] Identify cloud resources needed (compute, storage, networking, etc.)
- [ ] Determine environment stacks (dev, staging, prod)
- [ ] Plan resource dependencies and relationships
- [ ] Define configuration values and secrets
- [ ] Choose programming language (TypeScript recommended for type safety)
- [ ] Design component resources for reusability

### 2. Project Setup

**Create new project:**

```bash
pulumi new aws-typescript        # AWS with TypeScript
pulumi new kubernetes-python     # Kubernetes with Python
pulumi new azure-go             # Azure with Go
```

**Initialize stacks:**

```bash
pulumi stack init dev            # Create dev stack
pulumi stack init prod           # Create prod stack
pulumi stack select dev          # Switch to dev
```

**Project structure:**

```
my-infra/
├── Pulumi.yaml              # Project metadata
├── Pulumi.dev.yaml          # Dev stack config
├── Pulumi.prod.yaml         # Production config
├── index.ts                 # Infrastructure code
└── package.json             # Dependencies
```

### 3. Define Resources

**Basic resource pattern (TypeScript):**

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
    Environment: pulumi.getStack(),
    ManagedBy: "pulumi",
  },
});

// Export for reference
export const bucketName = bucket.id;
```

**For comprehensive patterns, see:**

- `references/pulumi-patterns.md` - Component resources, stack references, multi-provider
- `references/pulumi-aws-reference.md` - AWS-specific patterns and examples
- `references/pulumi-kubernetes-reference.md` - Kubernetes deployments and services

### 4. Configuration

**Set configuration:**

```bash
pulumi config set aws:region us-west-2
pulumi config set instanceCount 3
pulumi config set --secret dbPassword mySecretPass
```

**Read in code:**

```typescript
const config = new pulumi.Config();
const region = config.get("region") || "us-east-1";
const instanceCount = config.getNumber("instanceCount") || 1;
const dbPassword = config.requireSecret("dbPassword");
```

**Configuration files:**

```yaml
# Pulumi.dev.yaml
config:
  aws:region: us-west-2
  my-app:instanceCount: "1"
  my-app:dbPassword:
    secure: AAABAdzD... # Encrypted
```

### 5. Preview and Deploy

**Deployment workflow:**

```bash
# Preview changes
pulumi preview

# Deploy infrastructure
pulumi up

# View outputs
pulumi stack output

# Monitor logs
pulumi logs --follow
```

**Required checks before deployment:**

- [ ] Run `pulumi preview` to review changes
- [ ] Verify resource counts and operations (create/update/delete)
- [ ] Check configuration values are correct
- [ ] Ensure secrets are encrypted
- [ ] Review security group rules and access policies
- [ ] Confirm stack name is correct (dev/staging/prod)

### 6. Testing

**Test infrastructure deployments:**

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

  it("should create S3 bucket", async () => {
    stack = await pulumi.LocalWorkspace.createOrSelectStack({
      stackName: `test-${Date.now()}`,
      projectName: "test",
      program: async () => {
        const bucket = new aws.s3.Bucket("test", { acl: "private" });
        return { bucketName: bucket.id };
      },
    });

    await stack.setConfig("aws:region", { value: "us-west-2" });
    const result = await stack.up();

    expect(result.summary.result).toBe("succeeded");
    expect(result.outputs.bucketName).toBeDefined();
  });
});
```

**For testing patterns, see `references/pulumi-patterns.md`**

### 7. CI/CD Integration

**GitHub Actions:**

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

**For complete CI/CD patterns, see `references/pulumi-patterns.md`**

## Essential Patterns

### Component Resources

Create reusable infrastructure components:

```typescript
class WebService extends pulumi.ComponentResource {
  public readonly loadBalancerUrl: pulumi.Output<string>;

  constructor(
    name: string,
    args: WebServiceArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("custom:service:WebService", name, {}, opts);

    // Define resources (sg, lb, tg, listener)
    // ...

    this.registerOutputs({ loadBalancerUrl: lb.dnsName });
  }
}

// Usage
const web = new WebService("api", {
  vpcId: vpc.id,
  subnetIds: subnets.map((s) => s.id),
});
```

### Stack References

Share outputs between stacks:

```typescript
// networking/index.ts
export const vpcId = vpc.id;
export const publicSubnetIds = publicSubnets.map((s) => s.id);

// application/index.ts
const networkStack = new pulumi.StackReference("myOrg/networking/prod");
const vpcId = networkStack.getOutput("vpcId");
const subnetIds = networkStack.getOutput("publicSubnetIds");
```

### Automation API

Embed Pulumi in applications:

```typescript
import * as pulumi from "@pulumi/pulumi/automation";

const stack = await pulumi.LocalWorkspace.createOrSelectStack({
  stackName: "dev",
  projectName: "my-app",
  program: async () => {
    // Infrastructure code
  },
});

await stack.setConfig("aws:region", { value: "us-west-2" });
const result = await stack.up({ onOutput: console.log });
```

**For comprehensive patterns, see `references/pulumi-patterns.md`**

## Common Commands

```bash
# Project
pulumi new [template]           # Create project
pulumi stack init <name>        # Create stack
pulumi stack select <name>      # Switch stack
pulumi stack ls                 # List stacks

# Configuration
pulumi config set <key> <val>   # Set config
pulumi config set --secret <key> <val>  # Set secret
pulumi config                   # List config

# Deployment
pulumi preview                  # Preview changes
pulumi up                       # Deploy
pulumi up --yes                 # Deploy without prompt
pulumi destroy                  # Destroy resources
pulumi refresh                  # Sync state

# State
pulumi stack export > state.json    # Export state
pulumi stack import < state.json    # Import state
pulumi state delete <urn>           # Remove resource

# Outputs
pulumi stack output             # List outputs
pulumi stack output <key>       # Get output
```

**For complete CLI reference, see `references/pulumi-commands.md`**

## Best Practices

### Security

- Encrypt secrets with `pulumi config set --secret`
- Use least privilege IAM policies
- Default to private resources, explicit public exposure
- Network segmentation with VPCs and security groups

### State Management

- Use Pulumi Cloud or S3 backend for collaboration
- Enable state versioning and encryption
- Regular state backups with `pulumi stack export`
- Separate stacks for environments (dev/staging/prod)

### Code Organization

- Component resources for reusable abstractions
- Stack references for cross-stack dependencies
- Environment-specific config in `Pulumi.<stack>.yaml`
- TypeScript for type safety and validation

### Operations

- Always `pulumi preview` before `pulumi up`
- Deploy incremental changes, not large updates
- Test destroy and recreation procedures
- Monitor deployments with `pulumi logs`
- Document outputs for application consumption

## Resources

### references/

- `pulumi-patterns.md` - Component resources, stack references, testing, CI/CD patterns
- `pulumi-commands.md` - Complete CLI command reference
- `pulumi-aws-reference.md` - AWS provider patterns and examples
- `pulumi-kubernetes-reference.md` - Kubernetes deployments and services

## Quick Start Workflow

Complete workflow for deploying infrastructure:

1. **Initialize**: `pulumi new aws-typescript`
2. **Configure**: Set region, secrets with `pulumi config set`
3. **Define**: Write infrastructure code in `index.ts`
4. **Preview**: `pulumi preview` to review changes
5. **Deploy**: `pulumi up` to create resources
6. **Export**: `pulumi stack output --json > outputs.json`
7. **Test**: Verify resources created correctly
8. **CI/CD**: Set up GitHub Actions for automation
9. **Monitor**: Use `pulumi logs` and CloudWatch
10. **Document**: Update README with stack info

## Troubleshooting

**Resource already exists:**

```bash
pulumi import <type> <name> <id>  # Import existing resource
```

**State out of sync:**

```bash
pulumi refresh  # Sync state with cloud
```

**Dependency cycle:**

- Review resource dependencies
- Use explicit `dependsOn` if needed

**Permission denied:**

- Check IAM permissions
- Verify provider credentials

**Operation timeout:**

- Increase timeout in resource options
- Check resource health in cloud console

**Debug commands:**

```bash
pulumi stack --show-urns     # Show resource URNs
pulumi state delete <urn>    # Remove from state
pulumi refresh               # Sync with cloud
pulumi stack export > backup.json  # Backup before changes
```

## Common Scenarios

**"Deploy to multiple regions":**

- Create multiple AWS providers with different regions
- Use `provider` option when creating resources
- See `references/pulumi-patterns.md` for multi-region patterns

**"Share resources between stacks":**

- Export outputs from base stack
- Use `StackReference` in dependent stack
- See `references/pulumi-patterns.md` for stack reference patterns

**"Test infrastructure code":**

- Use Automation API for programmatic testing
- Create temporary stacks, deploy, verify, destroy
- See `references/pulumi-patterns.md` for testing patterns

**"Integrate with CI/CD":**

- Use Pulumi GitHub Actions
- Preview on PRs, deploy on merge
- See `references/pulumi-patterns.md` for complete workflows
