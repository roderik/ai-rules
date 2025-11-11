# Pulumi Infrastructure Patterns

Common infrastructure patterns and reusable component examples for Pulumi deployments.

## Component Resources

### Web Service Component

Reusable web service with load balancer and auto-scaling:

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

interface WebServiceArgs {
  instanceType: pulumi.Input<string>;
  desiredCapacity: pulumi.Input<number>;
  vpcId: pulumi.Input<string>;
  subnetIds: pulumi.Input<string[]>;
}

class WebService extends pulumi.ComponentResource {
  public readonly loadBalancerUrl: pulumi.Output<string>;
  public readonly securityGroupId: pulumi.Output<string>;

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
        vpcId: args.vpcId,
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
        subnets: args.subnetIds,
      },
      { parent: this },
    );

    // Target group
    const tg = new aws.lb.TargetGroup(
      `${name}-tg`,
      {
        port: 80,
        protocol: "HTTP",
        vpcId: args.vpcId,
        healthCheck: {
          path: "/health",
          interval: 30,
        },
      },
      { parent: this },
    );

    // Listener
    new aws.lb.Listener(
      `${name}-listener`,
      {
        loadBalancerArn: lb.arn,
        port: 80,
        defaultActions: [
          {
            type: "forward",
            targetGroupArn: tg.arn,
          },
        ],
      },
      { parent: this },
    );

    this.loadBalancerUrl = lb.dnsName;
    this.securityGroupId = sg.id;

    this.registerOutputs({
      loadBalancerUrl: this.loadBalancerUrl,
      securityGroupId: this.securityGroupId,
    });
  }
}

// Usage
const webService = new WebService("my-web-service", {
  instanceType: "t3.micro",
  desiredCapacity: 2,
  vpcId: vpc.id,
  subnetIds: publicSubnets.map((s) => s.id),
});

export const url = webService.loadBalancerUrl;
```

## Stack References

### Cross-Stack Dependencies

Export from networking stack:

```typescript
// networking/index.ts
import * as aws from "@pulumi/aws";

const vpc = new aws.ec2.Vpc("main", {
  cidrBlock: "10.0.0.0/16",
  enableDnsHostnames: true,
  enableDnsSupport: true,
});

const publicSubnets: aws.ec2.Subnet[] = [];
const privateSubnets: aws.ec2.Subnet[] = [];

const azs = ["us-west-2a", "us-west-2b", "us-west-2c"];

azs.forEach((az, index) => {
  publicSubnets.push(
    new aws.ec2.Subnet(`public-${az}`, {
      vpcId: vpc.id,
      cidrBlock: `10.0.${index}.0/24`,
      availabilityZone: az,
      mapPublicIpOnLaunch: true,
    }),
  );

  privateSubnets.push(
    new aws.ec2.Subnet(`private-${az}`, {
      vpcId: vpc.id,
      cidrBlock: `10.0.${100 + index}.0/24`,
      availabilityZone: az,
    }),
  );
});

// Exports for other stacks
export const vpcId = vpc.id;
export const publicSubnetIds = publicSubnets.map((s) => s.id);
export const privateSubnetIds = privateSubnets.map((s) => s.id);
```

Reference in application stack:

```typescript
// application/index.ts
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Reference networking stack
const networkStack = new pulumi.StackReference("myOrg/networking/prod");
const vpcId = networkStack.getOutput("vpcId");
const publicSubnetIds = networkStack.getOutput("publicSubnetIds");
const privateSubnetIds = networkStack.getOutput("privateSubnetIds");

// Use referenced outputs
const instance = new aws.ec2.Instance("app-instance", {
  instanceType: "t3.micro",
  ami: "ami-0c55b159cbfafe1f0",
  subnetId: privateSubnetIds[0],
  tags: {
    Name: "ApplicationServer",
  },
});
```

## Multi-Provider Patterns

### Multiple AWS Regions

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

// Cross-region replication
const replicationRole = new aws.iam.Role("replication", {
  assumeRolePolicy: JSON.stringify({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: { Service: "s3.amazonaws.com" },
        Action: "sts:AssumeRole",
      },
    ],
  }),
});

new aws.s3.BucketReplicationConfigurationV2(
  "replication-config",
  {
    bucket: westBucket.id,
    role: replicationRole.arn,
    rules: [
      {
        id: "replicate-all",
        status: "Enabled",
        destination: {
          bucket: eastBucket.arn,
        },
      },
    ],
  },
  { provider: usWest },
);
```

### Hybrid AWS + Kubernetes

```typescript
import * as aws from "@pulumi/aws";
import * as k8s from "@pulumi/kubernetes";
import * as eks from "@pulumi/eks";

// Create EKS cluster
const cluster = new eks.Cluster("my-cluster", {
  vpcId: vpc.id,
  subnetIds: privateSubnets.map((s) => s.id),
  instanceType: "t3.medium",
  desiredCapacity: 3,
  minSize: 1,
  maxSize: 5,
});

// Configure Kubernetes provider
const k8sProvider = new k8s.Provider("k8s", {
  kubeconfig: cluster.kubeconfig,
});

// Deploy namespace
const ns = new k8s.core.v1.Namespace(
  "app",
  {
    metadata: { name: "application" },
  },
  { provider: k8sProvider },
);

// Deploy application
const deployment = new k8s.apps.v1.Deployment(
  "app",
  {
    metadata: { namespace: ns.metadata.name },
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
              ports: [{ containerPort: 8080 }],
            },
          ],
        },
      },
    },
  },
  { provider: k8sProvider },
);

// Service
const service = new k8s.core.v1.Service(
  "app-service",
  {
    metadata: { namespace: ns.metadata.name },
    spec: {
      type: "LoadBalancer",
      selector: { app: "my-app" },
      ports: [{ port: 80, targetPort: 8080 }],
    },
  },
  { provider: k8sProvider },
);

export const clusterName = cluster.eksCluster.name;
export const serviceUrl = service.status.loadBalancer.ingress[0].hostname;
```

## Configuration Patterns

### Environment-Specific Configuration

```typescript
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();
const stack = pulumi.getStack();

// Environment-specific values
const instanceCount = config.getNumber("instanceCount") || 1;
const instanceType = config.get("instanceType") || "t3.micro";
const enableMonitoring = config.getBoolean("enableMonitoring") ?? true;

// Secret handling
const dbPassword = config.requireSecret("dbPassword");
const apiKey = config.requireSecret("apiKey");

// Computed configuration
const resourcePrefix = `${stack}-myapp`;
const tags = {
  Environment: stack,
  ManagedBy: "pulumi",
  Project: "my-project",
};

// Conditional resources based on stack
const isProd = stack === "production";
const backupRetentionDays = isProd ? 30 : 7;
```

Configuration files:

```yaml
# Pulumi.dev.yaml
config:
  aws:region: us-west-2
  my-app:instanceCount: "1"
  my-app:instanceType: t3.micro
  my-app:enableMonitoring: "false"
  my-app:dbPassword:
    secure: AAABAdzD...

# Pulumi.prod.yaml
config:
  aws:region: us-west-2
  my-app:instanceCount: "5"
  my-app:instanceType: t3.large
  my-app:enableMonitoring: "true"
  my-app:dbPassword:
    secure: AAABBefG...
```

## Testing Patterns

### Unit Testing with Automation API

```typescript
import { describe, it, expect, beforeEach, afterEach } from "bun:test";
import * as pulumi from "@pulumi/pulumi/automation";
import * as aws from "@pulumi/aws";

describe("S3 Bucket Tests", () => {
  let stack: pulumi.Stack;
  const stackName = `test-${Date.now()}`;

  beforeEach(async () => {
    stack = await pulumi.LocalWorkspace.createOrSelectStack({
      stackName,
      projectName: "test-project",
      program: async () => {
        const bucket = new aws.s3.Bucket("test-bucket", {
          acl: "private",
          serverSideEncryptionConfiguration: {
            rule: {
              applyServerSideEncryptionByDefault: {
                sseAlgorithm: "AES256",
              },
            },
          },
          tags: {
            Environment: "test",
          },
        });

        return {
          bucketName: bucket.id,
          bucketArn: bucket.arn,
        };
      },
    });

    await stack.setConfig("aws:region", { value: "us-west-2" });
  });

  afterEach(async () => {
    if (stack) {
      await stack.destroy({ onOutput: console.log });
      await stack.workspace.removeStack(stackName);
    }
  });

  it("should create encrypted S3 bucket", async () => {
    const upResult = await stack.up({ onOutput: console.log });

    expect(upResult.summary.result).toBe("succeeded");
    expect(upResult.outputs.bucketName).toBeDefined();
    expect(upResult.outputs.bucketArn.value).toContain("arn:aws:s3:::");
  });

  it("should export bucket name and ARN", async () => {
    await stack.up();
    const outputs = await stack.outputs();

    expect(outputs.bucketName).toBeDefined();
    expect(outputs.bucketArn).toBeDefined();
  });
});
```

### Integration Testing

```typescript
import { describe, it, expect } from "bun:test";
import * as pulumi from "@pulumi/pulumi/automation";
import * as aws from "@aws-sdk/client-s3";

describe("Integration Tests", () => {
  it("should deploy and verify infrastructure", async () => {
    const stack = await pulumi.LocalWorkspace.createOrSelectStack({
      stackName: "integration-test",
      projectName: "test-project",
      program: async () => {
        const bucket = new aws.s3.Bucket("test-bucket", {
          acl: "private",
        });
        return { bucketName: bucket.id };
      },
    });

    await stack.setConfig("aws:region", { value: "us-west-2" });

    // Deploy
    const upResult = await stack.up();
    const bucketName = upResult.outputs.bucketName.value;

    // Verify with AWS SDK
    const s3Client = new aws.S3Client({ region: "us-west-2" });
    const headResult = await s3Client.send(
      new aws.HeadBucketCommand({ Bucket: bucketName }),
    );

    expect(headResult.$metadata.httpStatusCode).toBe(200);

    // Cleanup
    await stack.destroy();
    await stack.workspace.removeStack("integration-test");
  });
});
```

## CI/CD Patterns

### GitHub Actions with Preview

```yaml
name: Pulumi Infrastructure
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  preview:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm install

      - uses: pulumi/actions@v4
        with:
          command: preview
          stack-name: prod
          comment-on-pr: true
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

  deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm install

      - uses: pulumi/actions@v4
        with:
          command: up
          stack-name: prod
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Export stack outputs
        run: pulumi stack output --json > outputs.json

      - name: Upload outputs
        uses: actions/upload-artifact@v3
        with:
          name: stack-outputs
          path: outputs.json
```

### GitOps with Automation API

```typescript
import * as pulumi from "@pulumi/pulumi/automation";
import { Octokit } from "@octokit/rest";

async function deployFromGitHub(
  repo: string,
  branch: string,
  stackName: string,
) {
  const stack = await pulumi.LocalWorkspace.createOrSelectStack({
    stackName,
    projectName: "my-app",
    url: `https://github.com/${repo}.git`,
    branch,
    auth: {
      personalAccessToken: process.env.GITHUB_TOKEN,
    },
  });

  // Configure stack
  await stack.setConfig("aws:region", { value: "us-west-2" });

  // Preview changes
  console.log("Previewing changes...");
  const previewResult = await stack.preview({ onOutput: console.log });

  if (previewResult.changeSummary.update > 0) {
    console.log(`Found ${previewResult.changeSummary.update} updates`);

    // Get approval (implement your approval logic)
    const approved = await getApproval();

    if (approved) {
      console.log("Deploying...");
      const upResult = await stack.up({ onOutput: console.log });
      console.log(`Deployment: ${upResult.summary.result}`);

      // Comment on PR with results
      await commentOnPR(repo, upResult);
    }
  }
}

async function getApproval(): Promise<boolean> {
  // Implement approval logic
  // Could be manual approval, automated checks, etc.
  return true;
}

async function commentOnPR(repo: string, result: any) {
  const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
  const [owner, repoName] = repo.split("/");

  await octokit.issues.createComment({
    owner,
    repo: repoName,
    issue_number: process.env.PR_NUMBER,
    body: `
## Pulumi Deployment

**Result:** ${result.summary.result}
**Resources Changed:** ${result.summary.resourceChanges.update || 0} updated, ${result.summary.resourceChanges.create || 0} created
    `,
  });
}
```
