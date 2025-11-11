# Evaluation Scenarios for rr-pulumi

## Scenario 1: Basic Usage - Create S3 Bucket with Encryption

**Input:** "Create a Pulumi program to deploy an encrypted S3 bucket with versioning enabled"

**Expected Behavior:**

- Automatically activate when "Pulumi" is mentioned
- Generate TypeScript code (preferred for type safety)
- Create S3 bucket with proper encryption configuration
- Enable versioning
- Add proper tags (Environment, ManagedBy)
- Export bucket name as output
- Use pulumi.getStack() for environment-specific naming
- Follow patterns from SKILL.md

**Success Criteria:**

- [ ] TypeScript code generated (index.ts)
- [ ] Imports @pulumi/aws and @pulumi/pulumi
- [ ] Bucket has serverSideEncryptionConfiguration with AES256
- [ ] Versioning enabled
- [ ] Tags include Environment and ManagedBy
- [ ] Exports bucket name/ID
- [ ] Uses pulumi.getStack() for environment awareness
- [ ] Follows coding style from SKILL.md examples

## Scenario 2: Complex Scenario - Multi-Stack Application with VPC

**Input:** "Set up a complete infrastructure with separate stacks for networking and application. The networking stack should create a VPC with public/private subnets. The application stack should reference the networking stack and deploy an ECS service with load balancer."

**Expected Behavior:**

- Load skill and understand multi-stack architecture
- Create two separate Pulumi projects or stacks
- Implement networking stack:
  - VPC with CIDR configuration
  - Public and private subnets
  - Internet gateway and NAT gateway
  - Route tables
  - Export VPC ID and subnet IDs
- Implement application stack:
  - Use StackReference to import networking outputs
  - Create ECS cluster
  - Create Application Load Balancer
  - Deploy ECS service
  - Configure security groups
- Reference `references/pulumi-patterns.md` for stack reference patterns
- Set up proper configuration for both stacks
- Show deployment workflow

**Success Criteria:**

- [ ] Two separate stacks created (networking and application)
- [ ] Networking stack exports: vpcId, publicSubnetIds, privateSubnetIds
- [ ] Application stack uses StackReference to import networking outputs
- [ ] VPC created with proper CIDR blocks
- [ ] Subnets distributed across availability zones
- [ ] Internet gateway and NAT gateway configured
- [ ] Load balancer created in public subnets
- [ ] ECS service created in private subnets
- [ ] Security groups configured with least privilege
- [ ] Configuration set for both stacks (pulumi config set)
- [ ] Preview step shown before deployment (pulumi preview)
- [ ] Proper tags on all resources
- [ ] References pulumi-patterns.md for stack reference pattern

## Scenario 3: Error Handling - Resource Already Exists

**Input:** "I'm trying to run 'pulumi up' but getting 'Resource already exists' error for my S3 bucket that was created manually outside of Pulumi."

**Expected Behavior:**

- Recognize the issue as existing resource conflict
- Explain that Pulumi doesn't know about manually created resource
- Provide solution using pulumi import
- Show correct import syntax for S3 bucket
- Explain the import process
- Verify resource URN format
- Reference troubleshooting section
- Suggest alternative: rename resource in code

**Success Criteria:**

- [ ] Identifies resource already exists as root cause
- [ ] Provides pulumi import command with correct syntax
- [ ] Shows how to get resource type and ID from AWS
- [ ] Example: pulumi import aws:s3/bucket:Bucket my-bucket existing-bucket-name
- [ ] Explains import updates state file
- [ ] Suggests running pulumi preview after import
- [ ] References troubleshooting section from SKILL.md
- [ ] Provides alternative solution (rename in code)
- [ ] Warns about state consistency
