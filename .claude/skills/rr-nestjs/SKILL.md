---
name: rr-nestjs
description: Comprehensive NestJS framework skill for building scalable server-side applications. Use for TypeScript backend development with controllers, providers, modules, dependency injection, middleware, guards, interceptors, pipes, database integration (MikroORM + MongoDB), GraphQL, microservices, testing, and API documentation. Automatically triggered when working with NestJS projects.
---

# NestJS Framework

## Overview

Professional TypeScript framework skill for building efficient, reliable, and scalable server-side applications. NestJS leverages Express or Fastify while providing an Angular-inspired architecture supporting OOP, FP, and FRP paradigms.

## When to Use This Skill

Automatically activate when:

- Working with NestJS project files (`nest-cli.json`, `main.ts`, `app.module.ts`)
- User mentions NestJS, Nest.js, or @nestjs packages
- Building REST APIs, GraphQL APIs, or microservices with TypeScript
- Using decorators like `@Controller()`, `@Injectable()`, `@Module()`
- User requests backend architecture, API development, or server-side TypeScript
- Working with MikroORM, MongoDB, or database integration in NestJS
- Implementing authentication, authorization, or API documentation

## Core Workflows

### 1. Project Setup and Structure

**Create new project:**

```bash
npm i -g @nestjs/cli
nest new my-app
cd my-app
npm run start:dev    # Hot-reload development mode
```

**Project structure:**

```
my-app/
├── src/
│   ├── main.ts                 # Application entry point
│   ├── app.module.ts           # Root module
│   ├── app.controller.ts       # Root controller
│   ├── app.service.ts          # Root service
│   └── modules/
│       ├── users/
│       │   ├── users.module.ts
│       │   ├── users.controller.ts
│       │   ├── users.service.ts
│       │   ├── dto/
│       │   │   ├── create-user.dto.ts
│       │   │   └── update-user.dto.ts
│       │   └── entities/
│       │       └── user.entity.ts
│       └── auth/
│           ├── auth.module.ts
│           ├── auth.service.ts
│           ├── guards/
│           │   └── jwt-auth.guard.ts
│           └── strategies/
│               └── jwt.strategy.ts
├── test/
│   ├── app.e2e-spec.ts
│   └── jest-e2e.json
├── nest-cli.json
├── tsconfig.json
└── package.json
```

### 2. Controllers (Request Handling)

**Basic controller:**

```typescript
import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  Delete,
  HttpCode,
  HttpStatus,
} from "@nestjs/common";
import { UsersService } from "./users.service";
import { CreateUserDto } from "./dto/create-user.dto";
import { UpdateUserDto } from "./dto/update-user.dto";

@Controller("users")
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get(":id")
  findOne(@Param("id") id: string) {
    return this.usersService.findOne(+id);
  }

  @Put(":id")
  update(@Param("id") id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(+id, updateUserDto);
  }

  @Delete(":id")
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param("id") id: string) {
    return this.usersService.remove(+id);
  }
}
```

**Request decorators:**

```typescript
import {
  Controller,
  Get,
  Req,
  Query,
  Headers,
  Ip,
  Session,
} from "@nestjs/common";
import { Request } from "express";

@Controller("example")
export class ExampleController {
  @Get()
  getExample(
    @Req() request: Request,
    @Query("search") search: string,
    @Headers("user-agent") userAgent: string,
    @Ip() ip: string,
    @Session() session: Record<string, any>,
  ) {
    return {
      search,
      userAgent,
      ip,
      path: request.path,
    };
  }
}
```

### 3. Providers & Services (Business Logic)

**Service with dependency injection:**

```typescript
import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@mikro-orm/nestjs";
import { EntityRepository } from "@mikro-orm/mongodb";
import { User } from "./entities/user.entity";
import { CreateUserDto } from "./dto/create-user.dto";
import { UpdateUserDto } from "./dto/update-user.dto";

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

  async findAll(): Promise<User[]> {
    return this.usersRepository.findAll();
  }

  async findOne(id: string): Promise<User> {
    const user = await this.usersRepository.findOne(id);
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id);
    Object.assign(user, updateUserDto);
    await this.usersRepository.flush();
    return user;
  }

  async remove(id: string): Promise<void> {
    const user = await this.findOne(id);
    await this.usersRepository.removeAndFlush(user);
  }
}
```

### 4. Modules (Organization)

**Feature module:**

```typescript
import { Module } from "@nestjs/common";
import { MikroOrmModule } from "@mikro-orm/nestjs";
import { UsersController } from "./users.controller";
import { UsersService } from "./users.service";
import { User } from "./entities/user.entity";

@Module({
  imports: [MikroOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService], // Export for use in other modules
})
export class UsersModule {}
```

**Root module:**

```typescript
import { Module } from "@nestjs/common";
import { MikroOrmModule } from "@mikro-orm/nestjs";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { UsersModule } from "./users/users.module";
import { AuthModule } from "./auth/auth.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ".env",
    }),
    MikroOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: "mongo",
        clientUrl: configService.get("MONGODB_URI"),
        dbName: configService.get("DB_NAME"),
        entities: ["./dist/**/*.entity.js"],
        entitiesTs: ["./src/**/*.entity.ts"],
        debug: configService.get("NODE_ENV") === "development",
      }),
      inject: [ConfigService],
    }),
    UsersModule,
    AuthModule,
  ],
})
export class AppModule {}
```

### 5. DTOs and Validation

**DTO with class-validator:**

```typescript
import { IsEmail, IsString, MinLength, IsOptional } from "class-validator";
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

  @ApiProperty({ example: "Software Engineer", required: false })
  @IsOptional()
  @IsString()
  role?: string;
}
```

**Global validation pipe:**

```typescript
import { ValidationPipe } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  await app.listen(3000);
}
bootstrap();
```

### 6. Guards (Authentication & Authorization)

**JWT authentication guard:**

```typescript
import { Injectable, ExecutionContext } from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";

@Injectable()
export class JwtAuthGuard extends AuthGuard("jwt") {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }
}
```

**Role-based authorization guard:**

```typescript
import { Injectable, CanActivate, ExecutionContext } from "@nestjs/common";
import { Reflector } from "@nestjs/core";

export const ROLES_KEY = "roles";
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredRoles) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}
```

**Usage in controller:**

```typescript
import { Controller, Get, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "./guards/jwt-auth.guard";
import { RolesGuard, Roles } from "./guards/roles.guard";

@Controller("admin")
@UseGuards(JwtAuthGuard, RolesGuard)
export class AdminController {
  @Get("users")
  @Roles("admin")
  getAllUsers() {
    return { message: "Admin-only endpoint" };
  }
}
```

### 7. Interceptors (Request/Response Transformation)

**Logging interceptor:**

```typescript
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from "@nestjs/common";
import { Observable } from "rxjs";
import { tap } from "rxjs/operators";

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger(LoggingInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url } = request;
    const now = Date.now();

    return next.handle().pipe(
      tap(() => {
        const response = context.switchToHttp().getResponse();
        const { statusCode } = response;
        const delay = Date.now() - now;
        this.logger.log(`${method} ${url} ${statusCode} - ${delay}ms`);
      }),
    );
  }
}
```

**Transform interceptor:**

```typescript
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from "@nestjs/common";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";

export interface Response<T> {
  data: T;
  timestamp: string;
}

@Injectable()
export class TransformInterceptor<T>
  implements NestInterceptor<T, Response<T>>
{
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<Response<T>> {
    return next.handle().pipe(
      map((data) => ({
        data,
        timestamp: new Date().toISOString(),
      })),
    );
  }
}
```

### 8. Middleware

**Logger middleware:**

```typescript
import { Injectable, NestMiddleware } from "@nestjs/common";
import { Request, Response, NextFunction } from "express";

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
  }
}
```

**Apply middleware:**

```typescript
import { Module, NestModule, MiddlewareConsumer } from "@nestjs/common";
import { LoggerMiddleware } from "./middleware/logger.middleware";
import { UsersController } from "./users/users.controller";

@Module({
  // ... module config
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(LoggerMiddleware).forRoutes(UsersController); // Or use '*' for all routes
  }
}
```

### 9. Exception Filters

**Custom exception filter:**

```typescript
import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from "@nestjs/common";
import { Request, Response } from "express";

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message:
        typeof exceptionResponse === "string"
          ? exceptionResponse
          : (exceptionResponse as any).message,
    });
  }
}
```

**Apply globally:**

```typescript
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import { HttpExceptionFilter } from "./filters/http-exception.filter";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalFilters(new HttpExceptionFilter());
  await app.listen(3000);
}
bootstrap();
```

### 10. Database Integration (MikroORM + MongoDB)

**Entity definition:**

```typescript
import { Entity, Property, PrimaryKey, Unique } from "@mikro-orm/core";
import { ObjectId } from "@mikro-orm/mongodb";

@Entity()
export class User {
  @PrimaryKey()
  _id!: ObjectId;

  @Property()
  id!: string;

  @Property()
  @Unique()
  email!: string;

  @Property()
  name!: string;

  @Property({ hidden: true })
  password!: string;

  @Property({ nullable: true })
  role?: string;

  @Property()
  createdAt = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt = new Date();
}
```

**Repository usage:**

See `references/nestjs-database.md` for comprehensive database patterns including:

- Entity relationships (OneToMany, ManyToOne, ManyToMany)
- EntityManager and Repository patterns
- Query builder and filtering
- Transactions and unit of work
- Migrations and seeders

### 11. Testing

**Unit testing services:**

```typescript
import { Test, TestingModule } from "@nestjs/testing";
import { getRepositoryToken } from "@mikro-orm/nestjs";
import { EntityRepository } from "@mikro-orm/mongodb";
import { UsersService } from "./users.service";
import { User } from "./entities/user.entity";

describe("UsersService", () => {
  let service: UsersService;
  let repository: EntityRepository<User>;

  const mockRepository = {
    create: jest.fn(),
    persistAndFlush: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
    removeAndFlush: jest.fn(),
    flush: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get<EntityRepository<User>>(getRepositoryToken(User));
  });

  it("should create a user", async () => {
    const createUserDto = {
      email: "test@example.com",
      name: "Test",
      password: "pass",
    };
    const user = { id: "1", ...createUserDto };

    mockRepository.create.mockReturnValue(user);
    mockRepository.persistAndFlush.mockResolvedValue(undefined);

    expect(await service.create(createUserDto)).toEqual(user);
  });
});
```

**E2E testing:**

```typescript
import { Test, TestingModule } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import * as request from "supertest";
import { AppModule } from "./../src/app.module";

describe("UsersController (e2e)", () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it("/users (GET)", () => {
    return request(app.getHttpServer())
      .get("/users")
      .expect(200)
      .expect((res) => {
        expect(Array.isArray(res.body)).toBe(true);
      });
  });

  afterAll(async () => {
    await app.close();
  });
});
```

### 12. API Documentation (Swagger)

**Setup Swagger:**

```typescript
import { NestFactory } from "@nestjs/core";
import { SwaggerModule, DocumentBuilder } from "@nestjs/swagger";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = new DocumentBuilder()
    .setTitle("My API")
    .setDescription("API documentation")
    .setVersion("1.0")
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api", app, document);

  await app.listen(3000);
}
bootstrap();
```

**Document endpoints:**

```typescript
import { Controller, Get, Post, Body } from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { CreateUserDto } from "./dto/create-user.dto";

@ApiTags("users")
@Controller("users")
export class UsersController {
  @Post()
  @ApiOperation({ summary: "Create a new user" })
  @ApiResponse({ status: 201, description: "User created successfully" })
  @ApiResponse({ status: 400, description: "Invalid input" })
  create(@Body() createUserDto: CreateUserDto) {
    // ...
  }

  @Get()
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get all users" })
  @ApiResponse({ status: 200, description: "List of users" })
  findAll() {
    // ...
  }
}
```

## Essential CLI Commands

```bash
# Project
nest new <project-name>          # Create new project
nest info                        # Display environment info

# Generate
nest g module <name>             # Generate module
nest g controller <name>         # Generate controller
nest g service <name>            # Generate service
nest g resource <name>           # Generate CRUD resource
nest g guard <name>              # Generate guard
nest g interceptor <name>        # Generate interceptor
nest g pipe <name>               # Generate pipe
nest g middleware <name>         # Generate middleware
nest g filter <name>             # Generate exception filter

# Development
npm run start                    # Start application
npm run start:dev                # Start with hot-reload
npm run start:debug              # Start in debug mode
npm run start:prod               # Start production build

# Build & Test
npm run build                    # Build application
npm run test                     # Run unit tests
npm run test:watch               # Run tests in watch mode
npm run test:cov                 # Run tests with coverage
npm run test:e2e                 # Run E2E tests
```

## Best Practices

### Architecture

1. **Module organization**: Group related features into modules
2. **Dependency injection**: Use constructor injection for testability
3. **Single responsibility**: Keep controllers thin, services focused
4. **Separation of concerns**: Controllers handle HTTP, services handle business logic
5. **DTO validation**: Always validate incoming data with class-validator

### Error Handling

1. **Use built-in exceptions**: `NotFoundException`, `BadRequestException`, etc.
2. **Custom filters**: Create exception filters for consistent error responses
3. **Validation errors**: Let ValidationPipe handle DTO validation errors
4. **Logging**: Log errors with context for debugging
5. **Error messages**: Provide clear, actionable error messages

### Security

1. **Authentication**: Implement JWT or session-based auth
2. **Authorization**: Use guards for role-based access control
3. **Validation**: Sanitize and validate all inputs
4. **CORS**: Configure CORS appropriately for your frontend
5. **Helmet**: Use helmet middleware for security headers
6. **Rate limiting**: Implement rate limiting with `@nestjs/throttler`

### Performance

1. **Caching**: Use `@nestjs/cache-manager` for response caching
2. **Database queries**: Optimize with proper indexing and query builders
3. **Lazy loading**: Load related entities only when needed
4. **Compression**: Enable gzip compression
5. **Logging**: Use appropriate log levels in production

### Testing

1. **Unit tests**: Test services with mocked dependencies
2. **E2E tests**: Test complete request/response cycles
3. **Coverage**: Aim for high test coverage on critical paths
4. **Mocking**: Mock external dependencies and databases
5. **Test organization**: Mirror source structure in test files

## Common Patterns

### Repository Pattern

See `references/nestjs-database.md` for complete MikroORM repository and EntityManager patterns.

## Resources

### references/

- `nestjs-database.md` - MikroORM + MongoDB integration, entities, queries, transactions

## Workflow Example

Complete workflow for building a REST API:

1. **Generate resource**: `nest g resource users`
2. **Define entity**: Create TypeORM entity with columns and relations
3. **Create DTOs**: Define create/update DTOs with validation
4. **Implement service**: Add business logic and repository operations
5. **Add authentication**: Implement JWT auth with guards
6. **Add authorization**: Create role-based guards
7. **Document API**: Add Swagger decorators
8. **Write tests**: Unit tests for service, E2E for endpoints
9. **Add error handling**: Custom exception filters
10. **Configure environment**: Use ConfigModule for env variables
11. **Setup logging**: Add logging interceptor
12. **Deploy**: Build and deploy to production

## Integration Patterns

### REST API with JWT Auth

```typescript
// main.ts - Complete setup
import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { SwaggerModule, DocumentBuilder } from "@nestjs/swagger";
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

  // Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Swagger
  const config = new DocumentBuilder()
    .setTitle("API")
    .setVersion("1.0")
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api", app, document);

  await app.listen(process.env.PORT || 3000);
}
bootstrap();
```

## Troubleshooting

### Common Issues

1. **Circular dependency**: Use `forwardRef()` or refactor module structure
2. **Can't resolve dependencies**: Ensure providers are exported from modules
3. **Validation not working**: Apply ValidationPipe globally or per-route
4. **Database connection fails**: Check environment variables and database status
5. **Swagger not showing types**: Add `@ApiProperty()` to DTO properties

### Debug Tips

```typescript
// Enable debug logging
const app = await NestFactory.create(AppModule, {
  logger: ['error', 'warn', 'log', 'debug', 'verbose'],
});

// Log dependency injection
import { Logger } from '@nestjs/common';
private readonly logger = new Logger(ClassName.name);
```
