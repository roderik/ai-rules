---
name: rr-nestjs
description: Comprehensive NestJS framework skill for building scalable server-side applications. Use for TypeScript backend development with controllers, providers, modules, dependency injection, middleware, guards, interceptors, pipes, database integration (MikroORM + MongoDB), GraphQL, microservices, testing, and API documentation. Also triggers when working with NestJS TypeScript files (.ts), NestJS module files, nest-cli.json, or NestJS project structure. Example triggers: "Create NestJS controller", "Set up dependency injection", "Add middleware", "Create GraphQL resolver", "Build microservice", "Write NestJS test", "Set up database module"
---

# NestJS Framework

Professional TypeScript framework for building efficient, reliable, and scalable server-side applications. NestJS leverages Express or Fastify with an Angular-inspired architecture.

## When to Use This Skill

Automatically activate when:

- Working with NestJS project files (`nest-cli.json`, `main.ts`, `app.module.ts`)
- User mentions NestJS, Nest.js, or @nestjs packages
- Building REST APIs, GraphQL APIs, or microservices with TypeScript
- Using decorators like `@Controller()`, `@Injectable()`, `@Module()`
- Working with MikroORM, MongoDB, or database integration
- Implementing authentication, authorization, or API documentation

## Development Workflow

### 1. Plan Architecture

**Before writing code:**

- [ ] Identify feature modules needed (users, auth, orders, etc.)
- [ ] Plan module dependencies and relationships
- [ ] Decide on authentication strategy (JWT, sessions, OAuth)
- [ ] Design database schema and entity relationships
- [ ] Define API endpoints and DTOs
- [ ] Determine shared services and utilities

### 2. Project Setup

**Create new project:**

```bash
npm i -g @nestjs/cli
nest new my-app
cd my-app
npm run start:dev    # Hot-reload development mode
```

**Standard project structure:**

```
my-app/
├── src/
│   ├── main.ts                 # Application entry point
│   ├── app.module.ts           # Root module
│   ├── shared/                 # Shared utilities and services
│   └── modules/                # Feature modules
│       ├── users/
│       │   ├── users.module.ts
│       │   ├── users.controller.ts
│       │   ├── users.service.ts
│       │   ├── dto/            # Data transfer objects
│       │   └── entities/       # Database entities
│       └── auth/
│           ├── auth.module.ts
│           ├── auth.service.ts
│           └── guards/
└── test/
    ├── app.e2e-spec.ts
    └── jest-e2e.json
```

### 3. Implement Features

**Core building blocks:**

1. **Controllers** - Handle HTTP requests, route to services
2. **Services** - Contain business logic, injected via DI
3. **Modules** - Organize related functionality
4. **DTOs** - Define and validate request/response shapes
5. **Guards** - Protect routes with authentication/authorization
6. **Interceptors** - Transform requests/responses
7. **Middleware** - Process requests before controllers
8. **Pipes** - Validate and transform data
9. **Filters** - Handle exceptions consistently

**For detailed implementation patterns, see:**

- `references/nestjs-patterns.md` - Complete code examples for all components
- `references/nestjs-database.md` - MikroORM integration and database patterns

**Quick generation:**

```bash
nest g resource users           # Generate complete CRUD module
nest g module auth              # Generate module
nest g controller users         # Generate controller
nest g service users            # Generate service
nest g guard auth/jwt-auth      # Generate guard
```

See `references/nestjs-commands.md` for complete CLI reference.

### 4. Testing

**Run comprehensive tests:**

```bash
# Unit tests with coverage
npm run test:cov

# E2E tests
npm run test:e2e

# Watch mode during development
npm run test:watch
```

**Required test coverage:**

- [ ] Unit tests for all services (>80% coverage)
- [ ] E2E tests for all endpoints
- [ ] Test authentication/authorization flows
- [ ] Test validation and error cases
- [ ] Mock external dependencies

See `references/nestjs-patterns.md` for testing patterns.

### 5. Quality Checks

**Before committing:**

```bash
# Lint code
npm run lint

# Format code
npm run format

# Run all tests
npm run test

# Build to verify no type errors
npm run build
```

### 6. Documentation

**API documentation with Swagger:**

```typescript
// main.ts
import { SwaggerModule, DocumentBuilder } from "@nestjs/swagger";

const config = new DocumentBuilder()
  .setTitle("My API")
  .setDescription("API documentation")
  .setVersion("1.0")
  .addBearerAuth()
  .build();

const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup("api", app, document);
```

**Document all endpoints:**

- Add `@ApiTags()` to controllers
- Add `@ApiOperation()` to methods
- Add `@ApiResponse()` for status codes
- Add `@ApiProperty()` to DTOs

## Essential Patterns

### Basic Feature Module

```typescript
// users.module.ts
import { Module } from "@nestjs/common";
import { MikroOrmModule } from "@mikro-orm/nestjs";
import { UsersController } from "./users.controller";
import { UsersService } from "./users.service";
import { User } from "./entities/user.entity";

@Module({
  imports: [MikroOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

### Controller with Validation

```typescript
// users.controller.ts
import { Controller, Get, Post, Body, Param, UseGuards } from "@nestjs/common";
import { ApiTags, ApiOperation, ApiBearerAuth } from "@nestjs/swagger";
import { UsersService } from "./users.service";
import { CreateUserDto } from "./dto/create-user.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";

@ApiTags("users")
@Controller("users")
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @ApiOperation({ summary: "Create a new user" })
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get all users" })
  findAll() {
    return this.usersService.findAll();
  }

  @Get(":id")
  findOne(@Param("id") id: string) {
    return this.usersService.findOne(id);
  }
}
```

### Service with Business Logic

```typescript
// users.service.ts
import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@mikro-orm/nestjs";
import { EntityRepository } from "@mikro-orm/mongodb";
import { User } from "./entities/user.entity";

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: EntityRepository<User>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.usersRepository.create(createUserDto);
    await this.usersRepository.persistAndFlush(user);
    return user;
  }

  async findOne(id: string): Promise<User> {
    const user = await this.usersRepository.findOne(id);
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }
}
```

### DTO with Validation

```typescript
// dto/create-user.dto.ts
import { IsEmail, IsString, MinLength } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class CreateUserDto {
  @ApiProperty({ example: "john@example.com" })
  @IsEmail()
  email: string;

  @ApiProperty({ example: "John Doe" })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({ example: "SecurePass123" })
  @IsString()
  @MinLength(8)
  password: string;
}
```

### Global Setup

```typescript
// main.ts - Production-ready setup
import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { AppModule } from "./app.module";
import * as helmet from "helmet";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security
  app.use(helmet());
  app.enableCors({
    origin: process.env.FRONTEND_URL,
    credentials: true,
  });

  // Global validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  await app.listen(process.env.PORT || 3000);
}
bootstrap();
```

## Best Practices Summary

### Architecture

- Group related features into modules
- Use dependency injection for all services
- Keep controllers thin, services focused
- Separate concerns (HTTP → business logic → data)

### Security

- Implement JWT authentication with `@nestjs/passport`
- Use guards for authorization
- Validate all inputs with DTOs
- Enable CORS, Helmet, rate limiting

### Error Handling

- Use built-in exceptions (`NotFoundException`, etc.)
- Implement global exception filters
- Log errors with context
- Return meaningful error messages

### Performance

- Use proper database indexes
- Implement caching for expensive operations
- Paginate list endpoints
- Enable gzip compression

### Testing

- Mock dependencies in unit tests
- Test complete flows in E2E tests
- Aim for >80% coverage on business logic
- Test authentication and error cases

**For complete best practices, see `references/nestjs-best-practices.md`**

## Common Commands

```bash
# Development
npm run start:dev               # Hot-reload development
npm run test:watch              # Tests in watch mode

# Generation
nest g resource <name>          # Complete CRUD module
nest g module <name>            # Module only
nest g controller <name>        # Controller only
nest g service <name>           # Service only

# Testing
npm run test                    # Unit tests
npm run test:cov                # With coverage
npm run test:e2e                # E2E tests

# Build
npm run build                   # Production build
npm run start:prod              # Run production
```

**For complete CLI reference, see `references/nestjs-commands.md`**

## Resources

### references/

- `nestjs-patterns.md` - Complete implementation patterns (controllers, services, guards, etc.)
- `nestjs-commands.md` - Full CLI command reference
- `nestjs-database.md` - MikroORM integration and database patterns
- `nestjs-best-practices.md` - Best practices, troubleshooting, and production checklist

## Quick Start Workflow

Complete workflow for building a REST API:

1. **Plan**: Identify modules, design schema, define endpoints
2. **Generate**: `nest g resource users`
3. **Define entity**: Create MikroORM entity with fields
4. **Create DTOs**: Add validation decorators
5. **Implement service**: Add business logic
6. **Add authentication**: JWT with guards
7. **Document API**: Add Swagger decorators
8. **Write tests**: Unit + E2E tests
9. **Run quality checks**: Lint, format, test, build
10. **Deploy**: Build and deploy to production

## Troubleshooting

**Circular dependency:**

```typescript
@Module({
  imports: [forwardRef(() => ModuleB)],
})
```

**Can't resolve dependencies:**

- Ensure service is in module `providers`
- Export if used in other modules

**Validation not working:**

- Apply `ValidationPipe` globally in `main.ts`

**Database connection fails:**

- Verify environment variables
- Check database is running

For detailed troubleshooting, see `references/nestjs-best-practices.md`
