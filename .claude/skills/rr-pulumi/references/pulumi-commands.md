# Pulumi CLI Commands Reference

Complete command reference for Pulumi CLI operations.

## Project and Stack Management

### Project Commands

```bash
# Create new project from template
pulumi new                         # Interactive template selection
pulumi new aws-typescript          # Specific template
pulumi new kubernetes-python       # Kubernetes with Python
pulumi new azure-go               # Azure with Go

# Project info
pulumi about                       # Display Pulumi version and info
pulumi version                     # Show Pulumi version
```

### Stack Commands

```bash
# Stack lifecycle
pulumi stack init <name>           # Create new stack
pulumi stack select <name>         # Switch to stack
pulumi stack ls                    # List all stacks
pulumi stack rm <name>             # Delete stack (prompts for confirmation)
pulumi stack rm <name> --yes       # Delete without confirmation

# Stack information
pulumi stack                       # Show current stack info
pulumi stack --show-urns          # Show resource URNs
pulumi stack graph               # Generate dependency graph
pulumi stack export              # Export stack state as JSON
pulumi stack import              # Import stack state from JSON

# Stack outputs
pulumi stack output              # List all outputs
pulumi stack output <key>        # Get specific output
pulumi stack output --json       # Output as JSON
pulumi stack output --show-secrets  # Show secret values
```

## Configuration Management

### Setting Configuration

```bash
# Basic configuration
pulumi config set <key> <value>              # Set config value
pulumi config set aws:region us-west-2       # Set provider config
pulumi config set instanceCount 3            # Set app config

# Secret configuration
pulumi config set --secret <key> <value>     # Set encrypted secret
pulumi config set --secret dbPassword pass123 # Secret example

# Configuration file paths
pulumi config set --path vpc.cidrBlock 10.0.0.0/16  # Nested config
```

### Reading Configuration

```bash
# Get configuration
pulumi config                     # List all config
pulumi config get <key>           # Get specific value
pulumi config get --json          # Output as JSON

# Remove configuration
pulumi config rm <key>            # Remove config value
```

## Deployment Operations

### Preview and Deploy

```bash
# Preview changes
pulumi preview                    # Preview changes
pulumi preview --diff             # Show detailed diff
pulumi preview --json             # Output as JSON
pulumi preview --target <urn>     # Preview specific resource

# Deploy infrastructure
pulumi up                         # Deploy with confirmation prompt
pulumi up --yes                   # Deploy without confirmation
pulumi up --skip-preview          # Deploy without preview
pulumi up --target <urn>          # Deploy specific resource
pulumi up --parallel <n>          # Set parallelism level

# Deployment options
pulumi up --refresh              # Refresh state before deploying
pulumi up --replace <urn>        # Force replacement of resource
pulumi up --target-replace <urn> # Replace specific resource
```

### Refresh and Destroy

```bash
# Refresh state
pulumi refresh                    # Sync state with cloud
pulumi refresh --yes              # Refresh without confirmation
pulumi refresh --target <urn>    # Refresh specific resource

# Destroy infrastructure
pulumi destroy                    # Destroy with confirmation
pulumi destroy --yes              # Destroy without confirmation
pulumi destroy --target <urn>    # Destroy specific resource
pulumi destroy --remove          # Remove from state without destroying
```

### Operation Management

```bash
# Cancel operations
pulumi cancel                     # Cancel current operation
pulumi cancel --yes              # Cancel without confirmation

# Watch for changes
pulumi watch                      # Watch for changes and auto-deploy
```

## State Management

### State Operations

```bash
# Export/import state
pulumi stack export > state.json        # Export state to file
pulumi stack import < state.json        # Import state from file

# State manipulation
pulumi state delete <urn>              # Remove resource from state
pulumi state unprotect <urn>           # Unprotect resource
pulumi import <type> <name> <id>       # Import existing resource
```

### Resource Management

```bash
# Resource operations
pulumi refresh <urn>                   # Refresh specific resource
pulumi destroy --target <urn>          # Destroy specific resource
pulumi up --target <urn>               # Update specific resource
```

## Plugin Management

### Plugin Commands

```bash
# List plugins
pulumi plugin ls                       # List installed plugins
pulumi plugin ls --project            # List project plugins

# Install plugins
pulumi plugin install resource aws     # Install AWS provider
pulumi plugin install resource aws 5.0.0  # Specific version

# Remove plugins
pulumi plugin rm resource aws          # Remove AWS provider
pulumi plugin rm resource aws 5.0.0   # Remove specific version
```

## Backend and Organization

### Backend Management

```bash
# Login to backend
pulumi login                           # Login to Pulumi Cloud
pulumi login --local                   # Use local backend
pulumi login s3://bucket-name          # Use S3 backend
pulumi login azblob://container        # Use Azure Blob backend

# Logout
pulumi logout                          # Logout from current backend
pulumi logout --all                    # Logout from all backends

# Backend info
pulumi whoami                          # Show current user
pulumi org ls                          # List organizations
```

### Organization Commands

```bash
# Stack management in org
pulumi stack ls --all                  # List all stacks in org
pulumi stack ls --project my-project   # List project stacks
pulumi stack select org/project/stack  # Select stack in org
```

## Development and Debugging

### Debugging

```bash
# Verbose output
pulumi up --verbose                    # Enable verbose logging
pulumi up -v                           # Short form
pulumi up --logtostderr               # Log to stderr
pulumi up --logflow                    # Show resource flow

# Debug options
pulumi up --debug                      # Enable debug mode
pulumi up --tracing <url>             # Enable tracing
```

### Logs and History

```bash
# View logs
pulumi logs                            # View recent logs
pulumi logs --follow                   # Follow logs in real-time
pulumi logs --since 1h                 # Logs from last hour
pulumi logs --resource <urn>          # Logs for specific resource

# History
pulumi history                         # Show deployment history
pulumi history --json                  # Output as JSON
pulumi history --show-secrets         # Show secret values
```

## Policy and Automation

### Policy Commands

```bash
# Policy packs
pulumi policy new <template>           # Create new policy pack
pulumi policy publish <org>           # Publish policy pack
pulumi policy enable <org>/<name>     # Enable policy pack
pulumi policy disable <org>/<name>    # Disable policy pack
pulumi policy ls                       # List policy packs
```

### Automation API

Use programmatically in code (not CLI commands):

```typescript
import * as pulumi from "@pulumi/pulumi/automation";

// Create stack programmatically
const stack = await pulumi.LocalWorkspace.createOrSelectStack({
  stackName: "dev",
  projectName: "my-app",
  program: async () => {
    // Infrastructure code here
  },
});

// Deploy
await stack.up();
```

## Useful Command Combinations

### Safe Deployment

```bash
# Preview, then deploy if approved
pulumi preview
# Review changes
pulumi up --yes
```

### Backup Before Changes

```bash
# Export state before changes
pulumi stack export > backup-$(date +%Y%m%d).json

# Make changes
pulumi up

# If needed, restore from backup
pulumi stack import < backup-20240101.json
```

### Multi-Stack Operations

```bash
# Deploy to dev
pulumi stack select dev
pulumi config set instanceCount 1
pulumi up --yes

# Deploy to staging
pulumi stack select staging
pulumi config set instanceCount 2
pulumi up --yes

# Deploy to prod
pulumi stack select prod
pulumi config set instanceCount 5
pulumi preview  # Review first
pulumi up --yes
```

### Targeted Updates

```bash
# Update only specific resource
pulumi up --target urn:pulumi:stack::project::aws:s3/bucket:Bucket::my-bucket

# Replace specific resource
pulumi up --replace urn:pulumi:stack::project::aws:ec2/instance:Instance::web-server
```

### Clean Up Resources

```bash
# Destroy specific resource
pulumi destroy --target <urn>

# Remove resource from state without destroying
pulumi state delete <urn>

# Destroy all resources
pulumi destroy --yes
```

## Environment Variables

Control Pulumi behavior with environment variables:

```bash
# Backend
export PULUMI_ACCESS_TOKEN=<token>        # Pulumi Cloud token
export PULUMI_BACKEND_URL=<url>           # Custom backend

# AWS credentials
export AWS_ACCESS_KEY_ID=<key>
export AWS_SECRET_ACCESS_KEY=<secret>
export AWS_REGION=us-west-2

# Kubernetes
export KUBECONFIG=/path/to/kubeconfig

# Behavior
export PULUMI_SKIP_UPDATE_CHECK=true      # Skip version check
export PULUMI_DEBUG_COMMANDS=true         # Debug CLI commands
export PULUMI_CONFIG_PASSPHRASE=<pass>    # Encryption passphrase
```

## Output Formats

Most commands support different output formats:

```bash
# JSON output
pulumi stack output --json
pulumi preview --json
pulumi history --json

# Plain output
pulumi stack output
pulumi config

# Specific output values
pulumi stack output vpcId
pulumi config get aws:region
```

## Common Workflows

### Initial Setup

```bash
pulumi new aws-typescript
pulumi config set aws:region us-west-2
pulumi config set --secret dbPassword mySecretPass
pulumi up
```

### Daily Development

```bash
pulumi stack select dev
pulumi preview  # Check changes
pulumi up      # Deploy
pulumi logs --follow  # Monitor
```

### Production Deployment

```bash
pulumi stack select prod
pulumi stack export > backup.json  # Backup
pulumi preview  # Review
pulumi up --yes  # Deploy
pulumi stack output --json > outputs.json  # Save outputs
```

### Troubleshooting

```bash
pulumi refresh  # Sync state
pulumi stack --show-urns  # Get URNs
pulumi state delete <urn>  # Remove bad resource
pulumi up --replace <urn>  # Force replace
```

### Migration

```bash
# Export from old stack
pulumi stack select old-stack
pulumi stack export > migration.json

# Import to new stack
pulumi stack select new-stack
pulumi stack import < migration.json
```
