# Pulumi AWS Provider Reference

## Overview

Pulumi's AWS Provider enables infrastructure-as-code management across Amazon Web Services using TypeScript, Python, Go, C#, Java, and YAML. The provider exposes the complete AWS API surface through strongly-typed interfaces, supporting 220+ AWS services.

## Key Features

- **Lambda functions** created directly from code via CallbackFunction without separate deployment packages
- **Type-safe IAM policy** definitions through PolicyDocument interfaces
- **Declarative event handling** for S3 and CloudWatch with inline function definitions
- **Multi-region deployments** using explicit provider instances
- **All AWS authentication methods** including IAM roles and OIDC federation

## Essential Resources

### Compute & Serverless

#### Lambda

```typescript
import * as aws from "@pulumi/aws";

// Lambda from inline code (CallbackFunction)
const lambda = new aws.lambda.CallbackFunction("my-function", {
  callback: async (event: any) => {
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Hello!" }),
    };
  },
  runtime: aws.lambda.Runtime.NodeJS18dX,
  timeout: 30,
  memorySize: 256,
  environment: {
    variables: {
      ENV: "production",
    },
  },
});

// Lambda from container image
const lambdaFromImage = new aws.lambda.Function("container-function", {
  packageType: "Image",
  imageUri: "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:latest",
  role: lambdaRole.arn,
  timeout: 30,
  memorySize: 512,
});
```

#### EC2

```typescript
import * as aws from "@pulumi/aws";

const instance = new aws.ec2.Instance("web-server", {
  instanceType: "t3.micro",
  ami: "ami-0c55b159cbfafe1f0", // Amazon Linux 2
  vpcSecurityGroupIds: [sg.id],
  subnetId: publicSubnet.id,
  keyName: "my-keypair",
  userData: `#!/bin/bash
echo "Hello World" > /var/www/html/index.html
systemctl start httpd
`,
  tags: {
    Name: "web-server",
    Environment: "production",
  },
});
```

#### ECS

```typescript
import * as aws from "@pulumi/aws";

const cluster = new aws.ecs.Cluster("app-cluster", {
  settings: [
    {
      name: "containerInsights",
      value: "enabled",
    },
  ],
});

const taskDefinition = new aws.ecs.TaskDefinition("app-task", {
  family: "app",
  cpu: "256",
  memory: "512",
  networkMode: "awsvpc",
  requiresCompatibilities: ["FARGATE"],
  containerDefinitions: JSON.stringify([
    {
      name: "app",
      image: "my-app:latest",
      portMappings: [
        {
          containerPort: 80,
          protocol: "tcp",
        },
      ],
      environment: [{ name: "ENV", value: "production" }],
    },
  ]),
});

const service = new aws.ecs.Service("app-service", {
  cluster: cluster.id,
  taskDefinition: taskDefinition.arn,
  desiredCount: 2,
  launchType: "FARGATE",
  networkConfiguration: {
    subnets: [subnet1.id, subnet2.id],
    securityGroups: [sg.id],
    assignPublicIp: true,
  },
});
```

### Storage & Databases

#### S3

```typescript
import * as aws from "@pulumi/aws";

const bucket = new aws.s3.Bucket("my-bucket", {
  acl: "private",
  versioning: {
    enabled: true,
  },
  serverSideEncryptionConfiguration: {
    rule: {
      applyServerSideEncryptionByDefault: {
        sseAlgorithm: "AES256",
      },
    },
  },
  lifecycleRules: [
    {
      enabled: true,
      transitions: [
        {
          days: 30,
          storageClass: "STANDARD_IA",
        },
        {
          days: 90,
          storageClass: "GLACIER",
        },
      ],
    },
  ],
  tags: {
    Environment: "production",
  },
});

// S3 bucket notification to Lambda
bucket.onObjectCreated("process-upload", lambda);
```

#### RDS

```typescript
import * as aws from "@pulumi/aws";

const dbSubnetGroup = new aws.rds.SubnetGroup("db-subnet-group", {
  subnetIds: [subnet1.id, subnet2.id],
});

const db = new aws.rds.Instance("postgres-db", {
  engine: "postgres",
  engineVersion: "14.7",
  instanceClass: "db.t3.micro",
  allocatedStorage: 20,
  storageType: "gp3",
  storageEncrypted: true,
  dbName: "myapp",
  username: "admin",
  password: dbPassword, // From Pulumi config secret
  dbSubnetGroupName: dbSubnetGroup.name,
  vpcSecurityGroupIds: [dbSg.id],
  skipFinalSnapshot: false,
  finalSnapshotIdentifier: "myapp-final-snapshot",
  backupRetentionPeriod: 7,
  multiAz: true,
  publiclyAccessible: false,
  tags: {
    Environment: "production",
  },
});
```

#### DynamoDB

```typescript
import * as aws from "@pulumi/aws";

const table = new aws.dynamodb.Table("users-table", {
  attributes: [
    { name: "userId", type: "S" },
    { name: "email", type: "S" },
  ],
  hashKey: "userId",
  rangeKey: "email",
  billingMode: "PAY_PER_REQUEST",
  globalSecondaryIndexes: [
    {
      name: "EmailIndex",
      hashKey: "email",
      projectionType: "ALL",
    },
  ],
  streamEnabled: true,
  streamViewType: "NEW_AND_OLD_IMAGES",
  ttl: {
    attributeName: "expiresAt",
    enabled: true,
  },
  tags: {
    Environment: "production",
  },
});
```

### Networking

#### VPC

```typescript
import * as aws from "@pulumi/aws";

const vpc = new aws.ec2.Vpc("main-vpc", {
  cidrBlock: "10.0.0.0/16",
  enableDnsHostnames: true,
  enableDnsSupport: true,
  tags: {
    Name: "main-vpc",
  },
});

const publicSubnet = new aws.ec2.Subnet("public-subnet", {
  vpcId: vpc.id,
  cidrBlock: "10.0.1.0/24",
  availabilityZone: "us-west-2a",
  mapPublicIpOnLaunch: true,
  tags: {
    Name: "public-subnet",
  },
});

const privateSubnet = new aws.ec2.Subnet("private-subnet", {
  vpcId: vpc.id,
  cidrBlock: "10.0.2.0/24",
  availabilityZone: "us-west-2a",
  tags: {
    Name: "private-subnet",
  },
});

const igw = new aws.ec2.InternetGateway("igw", {
  vpcId: vpc.id,
});

const publicRouteTable = new aws.ec2.RouteTable("public-rt", {
  vpcId: vpc.id,
  routes: [
    {
      cidrBlock: "0.0.0.0/0",
      gatewayId: igw.id,
    },
  ],
});

const publicRouteTableAssoc = new aws.ec2.RouteTableAssociation(
  "public-rt-assoc",
  {
    subnetId: publicSubnet.id,
    routeTableId: publicRouteTable.id,
  },
);
```

#### Security Groups

```typescript
import * as aws from "@pulumi/aws";

const webSg = new aws.ec2.SecurityGroup("web-sg", {
  vpcId: vpc.id,
  description: "Allow HTTP/HTTPS inbound traffic",
  ingress: [
    {
      protocol: "tcp",
      fromPort: 80,
      toPort: 80,
      cidrBlocks: ["0.0.0.0/0"],
      description: "Allow HTTP",
    },
    {
      protocol: "tcp",
      fromPort: 443,
      toPort: 443,
      cidrBlocks: ["0.0.0.0/0"],
      description: "Allow HTTPS",
    },
  ],
  egress: [
    {
      protocol: "-1",
      fromPort: 0,
      toPort: 0,
      cidrBlocks: ["0.0.0.0/0"],
      description: "Allow all outbound",
    },
  ],
  tags: {
    Name: "web-sg",
  },
});
```

#### API Gateway

```typescript
import * as aws from "@pulumi/aws";

const api = new aws.apigateway.RestApi("my-api", {
  description: "My REST API",
});

const resource = new aws.apigateway.Resource("users", {
  restApi: api.id,
  parentId: api.rootResourceId,
  pathPart: "users",
});

const method = new aws.apigateway.Method("getUsers", {
  restApi: api.id,
  resourceId: resource.id,
  httpMethod: "GET",
  authorization: "NONE",
});

const integration = new aws.apigateway.Integration("lambdaIntegration", {
  restApi: api.id,
  resourceId: resource.id,
  httpMethod: method.httpMethod,
  integrationHttpMethod: "POST",
  type: "AWS_PROXY",
  uri: lambda.invokeArn,
});

const deployment = new aws.apigateway.Deployment(
  "api-deployment",
  {
    restApi: api.id,
    stageName: "prod",
  },
  { dependsOn: [integration] },
);
```

### Management

#### IAM

```typescript
import * as aws from "@pulumi/aws";

const role = new aws.iam.Role("lambda-role", {
  assumeRolePolicy: JSON.stringify({
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          Service: "lambda.amazonaws.com",
        },
        Effect: "Allow",
      },
    ],
  }),
});

const policy = new aws.iam.RolePolicy("lambda-policy", {
  role: role.id,
  policy: JSON.stringify({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource: "arn:aws:logs:*:*:*",
      },
      {
        Effect: "Allow",
        Action: ["s3:GetObject", "s3:PutObject"],
        Resource: `${bucket.arn}/*`,
      },
    ],
  }),
});

// Attach managed policy
const policyAttachment = new aws.iam.RolePolicyAttachment(
  "lambda-exec-policy",
  {
    role: role.name,
    policyArn:
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  },
);
```

#### CloudWatch

```typescript
import * as aws from "@pulumi/aws";

const alarm = new aws.cloudwatch.MetricAlarm("high-cpu", {
  comparisonOperator: "GreaterThanThreshold",
  evaluationPeriods: 2,
  metricName: "CPUUtilization",
  namespace: "AWS/EC2",
  period: 120,
  statistic: "Average",
  threshold: 80,
  alarmDescription: "This metric monitors ec2 cpu utilization",
  alarmActions: [snsTopic.arn],
  dimensions: {
    InstanceId: instance.id,
  },
});

const logGroup = new aws.cloudwatch.LogGroup("app-logs", {
  retentionInDays: 7,
  tags: {
    Environment: "production",
  },
});
```

#### SNS

```typescript
import * as aws from "@pulumi/aws";

const topic = new aws.sns.Topic("alerts", {
  displayName: "Alert Notifications",
});

const subscription = new aws.sns.TopicSubscription("email-alert", {
  topic: topic.arn,
  protocol: "email",
  endpoint: "alerts@example.com",
});
```

## Integration Patterns

### Lambda + S3 Event Trigger

```typescript
import * as aws from "@pulumi/aws";

const bucket = new aws.s3.Bucket("uploads");
const lambda = new aws.lambda.CallbackFunction("processor", {
  callback: async (event: any) => {
    console.log("Processing upload:", event);
  },
});

// Automatic event subscription
bucket.onObjectCreated("process-upload", lambda);
```

### Lambda + API Gateway

```typescript
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";

const api = new awsx.apigateway.API("my-api", {
  routes: [
    {
      path: "/users",
      method: "GET",
      eventHandler: async (event) => {
        return {
          statusCode: 200,
          body: JSON.stringify({ users: [] }),
        };
      },
    },
  ],
});

export const apiUrl = api.url;
```

### ECS + ALB

```typescript
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";

const cluster = new aws.ecs.Cluster("app-cluster");

const lb = new awsx.lb.ApplicationLoadBalancer("app-lb", {
  subnetIds: publicSubnets.map((s) => s.id),
});

const service = new awsx.ecs.FargateService("app-service", {
  cluster: cluster.arn,
  taskDefinitionArgs: {
    container: {
      image: "my-app:latest",
      cpu: 256,
      memory: 512,
      portMappings: [
        {
          containerPort: 80,
          targetGroup: lb.defaultTargetGroup,
        },
      ],
    },
  },
});
```

## Best Practices

### Security

1. **Encrypt at rest**: Enable encryption for S3, RDS, EBS, DynamoDB
2. **Least privilege IAM**: Grant minimal necessary permissions
3. **VPC isolation**: Deploy resources in private subnets when possible
4. **Security groups**: Default deny, explicit allow only required ports
5. **Secrets management**: Use AWS Secrets Manager or Parameter Store

### Cost Optimization

1. **Auto-scaling**: Use auto-scaling groups for EC2, ECS
2. **Right-sizing**: Match instance types to workload requirements
3. **Reserved instances**: Use for predictable, long-running workloads
4. **S3 lifecycle policies**: Transition to cheaper storage classes
5. **Lambda memory**: Optimize memory allocation for cost/performance

### Reliability

1. **Multi-AZ**: Deploy across availability zones
2. **Health checks**: Configure ALB/ELB health checks
3. **Backups**: Enable automated backups for RDS, snapshots for EBS
4. **Monitoring**: Set up CloudWatch alarms for critical metrics
5. **Graceful degradation**: Implement circuit breakers, retries

### Operational Excellence

1. **Tagging**: Consistent tagging strategy for cost tracking
2. **CloudWatch Logs**: Centralized logging for all services
3. **Infrastructure as Code**: All resources defined in Pulumi
4. **CI/CD**: Automated testing and deployment pipelines
5. **Documentation**: Export outputs, maintain README with architecture

## Common Use Cases

### Serverless Web Application

- **API Gateway** for REST API
- **Lambda** for business logic
- **DynamoDB** for data persistence
- **S3** for static assets
- **CloudFront** for CDN

### Microservices on ECS

- **ECS Fargate** for container orchestration
- **Application Load Balancer** for traffic distribution
- **RDS** for relational data
- **ElastiCache** for caching
- **CloudWatch** for monitoring

### Data Processing Pipeline

- **S3** for data lake storage
- **Lambda** for ETL processing
- **Kinesis** for streaming data
- **Glue** for data cataloging
- **Athena** for querying

### High-Availability Web Application

- **EC2 Auto Scaling** across multiple AZs
- **Application Load Balancer** with health checks
- **RDS Multi-AZ** for database redundancy
- **ElastiCache Redis** for session storage
- **Route53** for DNS and health-based routing
