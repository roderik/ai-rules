# NestJS Best Practices

Comprehensive guide to best practices, common patterns, and troubleshooting for NestJS applications.

## Architecture Best Practices

### Module Organization

1. **Group related features into modules** - Keep cohesive functionality together
2. **Use feature modules** - Separate concerns (users, auth, orders, etc.)
3. **Shared module for common code** - Create a shared module for utilities and common services
4. **Keep modules focused** - Each module should have a single responsibility
5. **Export services carefully** - Only export what other modules need to use

**Example structure:**

```
src/
├── shared/
│   ├── shared.module.ts
│   └── services/
│       ├── logger.service.ts
│       └── config.service.ts
├── users/
│   ├── users.module.ts
│   ├── users.controller.ts
│   └── users.service.ts
└── auth/
    ├── auth.module.ts
    ├── auth.controller.ts
    └── auth.service.ts
```

### Dependency Injection

1. **Use constructor injection** - Preferred for required dependencies
2. **Avoid circular dependencies** - Use `forwardRef()` only as last resort
3. **Keep constructors lean** - Initialize in `onModuleInit()` if complex setup needed
4. **Use providers for business logic** - Keep controllers thin
5. **Inject repositories, not EntityManager** - More testable and explicit

### Controller Design

1. **Controllers handle HTTP only** - No business logic
2. **Keep methods small** - Delegate to services
3. **Use DTOs for validation** - Never trust incoming data
4. **Return proper HTTP status codes** - Use `@HttpCode()` decorator
5. **Use route guards** - Protect endpoints with authentication/authorization
6. **Document with Swagger** - Add `@Api*()` decorators

### Service Design

1. **Single responsibility** - Each service should do one thing well
2. **Services contain business logic** - Not controllers
3. **Use transactions for related operations** - Maintain data consistency
4. **Return domain objects, not DTOs** - Let controllers handle transformation
5. **Throw descriptive exceptions** - Use NestJS built-in exceptions
6. **Keep services testable** - Inject all dependencies

## Security Best Practices

### Authentication & Authorization

1. **Implement JWT authentication** - Use `@nestjs/passport` and `@nestjs/jwt`
2. **Store secrets in environment variables** - Never hardcode credentials
3. **Use bcrypt for password hashing** - Never store plain text passwords
4. **Implement refresh tokens** - For better security and UX
5. **Use guards for route protection** - `@UseGuards()` decorator
6. **Role-based access control (RBAC)** - Implement with custom guards
7. **Validate all inputs** - Use DTOs with `class-validator`

### Input Validation

1. **Use ValidationPipe globally** - Validate all incoming requests
2. **Whitelist properties** - Set `whitelist: true` to strip unknown properties
3. **Forbid non-whitelisted** - Set `forbidNonWhitelisted: true` to reject bad requests
4. **Transform inputs** - Use `transform: true` for automatic type conversion
5. **Sanitize HTML inputs** - Prevent XSS attacks
6. **Validate file uploads** - Check file types and sizes

### Security Headers & CORS

1. **Use Helmet** - Set security headers automatically
2. **Configure CORS properly** - Only allow trusted origins
3. **Implement rate limiting** - Use `@nestjs/throttler`
4. **Enable CSRF protection** - For session-based auth
5. **Use HTTPS in production** - Never serve sensitive data over HTTP

**Example:**

```typescript
import * as helmet from "helmet";

app.use(helmet());
app.enableCors({
  origin: process.env.FRONTEND_URL,
  credentials: true,
});
```

## Error Handling Best Practices

### Exception Handling

1. **Use built-in exceptions** - `NotFoundException`, `BadRequestException`, etc.
2. **Create custom exceptions** - When built-in ones don't fit
3. **Implement exception filters** - For consistent error responses
4. **Log errors with context** - Include request ID, user, timestamp
5. **Never expose stack traces** - In production responses
6. **Return meaningful error messages** - Help clients debug issues

**Standard exception types:**

```typescript
BadRequestException(400);
UnauthorizedException(401);
ForbiddenException(403);
NotFoundException(404);
ConflictException(409);
InternalServerErrorException(500);
```

### Validation Errors

1. **Let ValidationPipe handle DTO errors** - Automatic validation
2. **Return detailed validation errors** - Help clients fix issues
3. **Use custom error messages** - In validation decorators
4. **Group related validations** - Use validation groups if needed

## Performance Best Practices

### Database Optimization

1. **Use proper indexes** - On frequently queried fields
2. **Eager load relationships carefully** - Avoid N+1 queries
3. **Use pagination** - For list endpoints
4. **Implement caching** - For frequently accessed data
5. **Use database transactions** - For related operations
6. **Lazy load when possible** - Load only what's needed
7. **Monitor query performance** - Enable query logging in development

### Caching

1. **Use `@nestjs/cache-manager`** - Built-in caching support
2. **Cache expensive operations** - Database queries, external APIs
3. **Set appropriate TTL** - Balance freshness and performance
4. **Implement cache invalidation** - When data changes
5. **Use Redis for distributed caching** - In multi-instance deployments

**Example:**

```typescript
import { CacheInterceptor, CacheTTL } from "@nestjs/cache-manager";

@Controller("users")
@UseInterceptors(CacheInterceptor)
export class UsersController {
  @Get()
  @CacheTTL(30) // 30 seconds
  findAll() {
    return this.usersService.findAll();
  }
}
```

### API Response Optimization

1. **Compress responses** - Enable gzip compression
2. **Return only needed fields** - Use DTOs to shape responses
3. **Implement pagination** - For large result sets
4. **Use streaming** - For large file downloads
5. **Optimize serialization** - Remove unnecessary data

## Testing Best Practices

### Unit Testing

1. **Test services with mocked dependencies** - Isolated testing
2. **Use TestingModule** - NestJS testing utilities
3. **Mock repositories and external services** - Don't hit real databases
4. **Test error cases** - Not just happy paths
5. **Aim for high coverage** - Especially on business logic
6. **Keep tests simple** - Test one thing per test

### E2E Testing

1. **Test complete request/response cycles** - Real integration tests
2. **Use test database** - Separate from development
3. **Clean up after tests** - Reset state between tests
4. **Test authentication flows** - Including JWT tokens
5. **Test error responses** - Validation, auth failures, etc.

### Test Organization

1. **Mirror source structure** - Place tests near source files
2. **Use descriptive test names** - "should create user when valid data provided"
3. **Setup and teardown properly** - Use `beforeEach`, `afterEach`
4. **Group related tests** - Use `describe` blocks
5. **Mock external dependencies** - HTTP clients, message queues, etc.

## Code Quality Best Practices

### TypeScript Usage

1. **Enable strict mode** - `"strict": true` in tsconfig
2. **Use proper types** - Avoid `any`
3. **Use interfaces for DTOs** - Or classes with decorators
4. **Type all function parameters** - And return types
5. **Use generics** - For reusable code

### Code Organization

1. **Follow naming conventions** - `users.controller.ts`, `users.service.ts`
2. **Keep files small** - Extract large classes
3. **Use barrel exports** - `index.ts` files for cleaner imports
4. **Group related code** - DTOs in `dto/`, entities in `entities/`
5. **Comment complex logic** - Explain the "why", not the "what"

### Logging

1. **Use built-in Logger** - `@nestjs/common`
2. **Log with appropriate levels** - Error, warn, log, debug, verbose
3. **Include context** - Service name, user, request ID
4. **Don't log sensitive data** - Passwords, tokens, PII
5. **Use structured logging** - For easier parsing

**Example:**

```typescript
import { Logger } from "@nestjs/common";

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  async findOne(id: string) {
    this.logger.log(`Finding user with id: ${id}`);
    // ...
  }
}
```

## Common Patterns

### Repository Pattern

Use MikroORM repositories for database access - see `nestjs-database.md` for details.

### DTO Pattern

Always use DTOs for request/response transformation:

```typescript
// Request DTO
export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  name: string;
}

// Response DTO
export class UserResponseDto {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
}
```

### Service Layer Pattern

Keep business logic in services, not controllers:

```typescript
@Controller("users")
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  create(@Body() dto: CreateUserDto) {
    return this.usersService.create(dto); // Delegate to service
  }
}
```

## Troubleshooting

### Common Issues

**1. Circular Dependency**

```typescript
// Problem: Module A imports Module B, which imports Module A

// Solution: Use forwardRef()
@Module({
  imports: [forwardRef(() => ModuleB)],
})
export class ModuleA {}
```

**2. Can't Resolve Dependencies**

```typescript
// Problem: Service not provided in module

// Solution: Add to module providers
@Module({
  providers: [UsersService], // Add here
  exports: [UsersService], // Export if used in other modules
})
export class UsersModule {}
```

**3. Validation Not Working**

```typescript
// Problem: ValidationPipe not applied

// Solution: Apply globally in main.ts
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }),
);
```

**4. Database Connection Fails**

```typescript
// Problem: Wrong connection string or database not running

// Solution: Check environment variables
console.log(process.env.MONGODB_URI);

// Check database is running
# For MongoDB
mongosh $MONGODB_URI
```

**5. Swagger Not Showing Types**

```typescript
// Problem: Missing @ApiProperty decorators

// Solution: Add to all DTO properties
export class CreateUserDto {
  @ApiProperty()
  @IsEmail()
  email: string;
}
```

### Debug Tips

**Enable verbose logging:**

```typescript
const app = await NestFactory.create(AppModule, {
  logger: ["error", "warn", "log", "debug", "verbose"],
});
```

**Debug dependency injection:**

```typescript
import { Logger } from "@nestjs/common";

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor() {
    this.logger.debug("UsersService instantiated");
  }
}
```

**Check module imports:**

```bash
# Use nest CLI to see module structure
nest info
```

## Production Checklist

Before deploying to production:

- [ ] Enable production mode (`NODE_ENV=production`)
- [ ] Use environment variables for configuration
- [ ] Enable HTTPS
- [ ] Configure CORS with specific origins
- [ ] Implement rate limiting
- [ ] Set up error logging (Sentry, LogRocket, etc.)
- [ ] Enable compression
- [ ] Set up health checks
- [ ] Configure proper logging levels
- [ ] Implement graceful shutdown
- [ ] Set up monitoring and alerting
- [ ] Use production database credentials
- [ ] Remove debug logging
- [ ] Enable Helmet for security headers
- [ ] Test error scenarios
- [ ] Set up CI/CD pipeline
- [ ] Document API with Swagger
- [ ] Implement proper backup strategy
- [ ] Configure connection pooling
- [ ] Test with production-like data volume
