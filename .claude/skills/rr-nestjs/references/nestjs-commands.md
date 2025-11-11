# NestJS CLI Commands Reference

Complete command reference for NestJS CLI and common operations.

## Project Commands

```bash
# Create new project
nest new <project-name>

# Display environment info
nest info

# Start application
npm run start                    # Standard mode
npm run start:dev                # Development with hot-reload
npm run start:debug              # Debug mode
npm run start:prod               # Production build

# Build application
npm run build

# Run linting
npm run lint
npm run lint:fix                 # Auto-fix linting issues

# Format code
npm run format
```

## Generate Commands

### Modules and Components

```bash
# Generate module
nest g module <name>
nest g mo <name>                 # Short form

# Generate controller
nest g controller <name>
nest g co <name>                 # Short form

# Generate service
nest g service <name>
nest g s <name>                  # Short form

# Generate complete CRUD resource (module + controller + service + DTOs + entities)
nest g resource <name>
nest g res <name>                # Short form
```

### Middleware and Filters

```bash
# Generate guard
nest g guard <name>
nest g gu <name>                 # Short form

# Generate interceptor
nest g interceptor <name>
nest g in <name>                 # Short form

# Generate pipe
nest g pipe <name>
nest g pi <name>                 # Short form

# Generate middleware
nest g middleware <name>
nest g mi <name>                 # Short form

# Generate exception filter
nest g filter <name>
nest g f <name>                  # Short form
```

### Advanced Components

```bash
# Generate gateway (WebSockets)
nest g gateway <name>
nest g ga <name>                 # Short form

# Generate decorator
nest g decorator <name>
nest g d <name>                  # Short form

# Generate class
nest g class <name>
nest g cl <name>                 # Short form

# Generate interface
nest g interface <name>
nest g i <name>                  # Short form
```

## Generate Options

```bash
# Generate without spec file
nest g service <name> --no-spec

# Generate in specific directory
nest g service users/services/user
nest g module users/users

# Generate flat (no directory)
nest g service <name> --flat

# Dry run (preview changes without creating files)
nest g service <name> --dry-run
```

## Testing Commands

```bash
# Run unit tests
npm run test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:cov

# Run E2E tests
npm run test:e2e

# Run specific test file
npm run test -- <filename>

# Run tests matching pattern
npm run test -- --testNamePattern="UserService"
```

## Database Commands (MikroORM)

```bash
# Generate migration
npx mikro-orm migration:create

# Run migrations
npx mikro-orm migration:up

# Rollback migration
npx mikro-orm migration:down

# List migrations
npx mikro-orm migration:list

# Generate entity from database
npx mikro-orm generate-entities

# Create database schema
npx mikro-orm schema:create

# Update database schema
npx mikro-orm schema:update

# Drop database schema
npx mikro-orm schema:drop

# Seed database
npx mikro-orm seeder:run
```

## Debug Commands

```bash
# Start with Node debugger
npm run start:debug

# Attach to running process
node --inspect-brk dist/main.js

# Debug tests
node --inspect-brk node_modules/.bin/jest --runInBand

# Enable verbose logging
NODE_ENV=development npm run start:dev
```

## Production Commands

```bash
# Build for production
npm run build

# Run production build
node dist/main.js

# Build with custom tsconfig
nest build --config tsconfig.production.json

# Watch mode for build
nest build --watch

# Clean build output
rm -rf dist
```

## Package Management

```bash
# Install dependencies
npm install

# Add NestJS package
npm install @nestjs/<package-name>

# Add common packages
npm install @nestjs/config          # Configuration
npm install @nestjs/swagger          # API documentation
npm install @nestjs/passport         # Authentication
npm install @nestjs/jwt              # JWT tokens
npm install @nestjs/throttler        # Rate limiting
npm install @nestjs/cache-manager    # Caching
npm install @nestjs/schedule         # Scheduled tasks
npm install @nestjs/websockets       # WebSockets
npm install @nestjs/microservices    # Microservices

# Install MikroORM
npm install @mikro-orm/core @mikro-orm/nestjs @mikro-orm/mongodb

# Install validation
npm install class-validator class-transformer

# Install testing utilities
npm install --save-dev @nestjs/testing supertest
```

## Common Workflows

### Create New Feature Module

```bash
# Generate complete CRUD resource
nest g resource users

# Or manually create components
nest g module users
nest g controller users
nest g service users
nest g class users/dto/create-user.dto --no-spec
nest g class users/dto/update-user.dto --no-spec
nest g class users/entities/user.entity --no-spec
```

### Add Authentication

```bash
# Generate auth module
nest g module auth
nest g service auth
nest g controller auth

# Generate guards and strategies
nest g guard auth/guards/jwt-auth
nest g guard auth/guards/local-auth
nest g class auth/strategies/jwt.strategy --no-spec
nest g class auth/strategies/local.strategy --no-spec
```

### Add API Documentation

```bash
# Install Swagger
npm install @nestjs/swagger

# Generate DTO with Swagger decorators
nest g class users/dto/create-user.dto --no-spec
```

### Setup Testing

```bash
# Run unit tests
npm run test

# Generate test coverage
npm run test:cov

# Run E2E tests
npm run test:e2e

# Run tests in watch mode during development
npm run test:watch
```

## Project Structure Commands

```bash
# View project structure
tree -I 'node_modules|dist'

# Count lines of code
find src -name '*.ts' | xargs wc -l

# Find all controllers
find src -name '*.controller.ts'

# Find all services
find src -name '*.service.ts'

# Find all tests
find . -name '*.spec.ts' -o -name '*.e2e-spec.ts'
```

## Troubleshooting Commands

```bash
# Clear npm cache
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Verify NestJS installation
nest --version
nest info

# Check for outdated packages
npm outdated

# Update packages
npm update

# Check for security vulnerabilities
npm audit
npm audit fix
```
