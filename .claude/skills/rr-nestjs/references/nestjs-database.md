# NestJS Database Integration with TypeORM

## Overview

Comprehensive guide for TypeORM integration with NestJS, covering entity relationships, advanced queries, transactions, migrations, and best practices.

## Setup and Configuration

### Install Dependencies

```bash
npm install @nestjs/typeorm typeorm pg
# Or for MySQL
npm install @nestjs/typeorm typeorm mysql2
```

### Configure TypeORM Module

```typescript
import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { ConfigModule, ConfigService } from "@nestjs/config";

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: "postgres",
        host: configService.get("DB_HOST"),
        port: configService.get("DB_PORT"),
        username: configService.get("DB_USERNAME"),
        password: configService.get("DB_PASSWORD"),
        database: configService.get("DB_DATABASE"),
        entities: [__dirname + "/**/*.entity{.ts,.js}"],
        synchronize: configService.get("NODE_ENV") !== "production",
        logging: configService.get("NODE_ENV") === "development",
      }),
      inject: [ConfigService],
    }),
  ],
})
export class AppModule {}
```

## Entity Relationships

### One-to-Many / Many-to-One

```typescript
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from "typeorm";

@Entity("users")
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @OneToMany(() => Post, (post) => post.author)
  posts: Post[];
}

@Entity("posts")
export class Post {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column()
  content: string;

  @ManyToOne(() => User, (user) => user.posts)
  @JoinColumn({ name: "author_id" })
  author: User;

  @Column({ name: "author_id" })
  authorId: number;
}
```

### Many-to-Many

```typescript
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToMany,
  JoinTable,
} from "typeorm";

@Entity("users")
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @ManyToMany(() => Role, (role) => role.users)
  @JoinTable({
    name: "user_roles",
    joinColumn: { name: "user_id", referencedColumnName: "id" },
    inverseJoinColumn: { name: "role_id", referencedColumnName: "id" },
  })
  roles: Role[];
}

@Entity("roles")
export class Role {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  name: string;

  @ManyToMany(() => User, (user) => user.roles)
  users: User[];
}
```

### Self-Referencing

```typescript
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from "typeorm";

@Entity("categories")
export class Category {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @ManyToOne(() => Category, (category) => category.children)
  @JoinColumn({ name: "parent_id" })
  parent: Category;

  @OneToMany(() => Category, (category) => category.parent)
  children: Category[];
}
```

## Repository Operations

### Basic CRUD

```typescript
import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { User } from "./entities/user.entity";

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  // Create
  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.usersRepository.create(createUserDto);
    return this.usersRepository.save(user);
  }

  // Read all
  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  // Read one
  async findOne(id: number): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }

  // Update
  async update(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    await this.usersRepository.update(id, updateUserDto);
    return this.findOne(id);
  }

  // Delete
  async remove(id: number): Promise<void> {
    const result = await this.usersRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`User #${id} not found`);
    }
  }
}
```

### Loading Relations

```typescript
// Eager loading with relations
async findUserWithPosts(id: number): Promise<User> {
  return this.usersRepository.findOne({
    where: { id },
    relations: ['posts', 'roles'],
  });
}

// Select specific fields
async findUserEmails(): Promise<{ id: number; email: string }[]> {
  return this.usersRepository.find({
    select: ['id', 'email'],
  });
}

// Nested relations
async findUserWithPostsAndComments(id: number): Promise<User> {
  return this.usersRepository.findOne({
    where: { id },
    relations: ['posts', 'posts.comments', 'posts.comments.author'],
  });
}
```

### Query Builder

```typescript
// Basic query builder
async findActiveUsers(): Promise<User[]> {
  return this.usersRepository
    .createQueryBuilder('user')
    .where('user.isActive = :isActive', { isActive: true })
    .orderBy('user.createdAt', 'DESC')
    .getMany();
}

// Complex queries with joins
async findUsersWithPosts(): Promise<User[]> {
  return this.usersRepository
    .createQueryBuilder('user')
    .leftJoinAndSelect('user.posts', 'post')
    .where('post.published = :published', { published: true })
    .andWhere('user.isActive = :isActive', { isActive: true })
    .orderBy('post.createdAt', 'DESC')
    .getMany();
}

// Pagination
async findWithPagination(
  page: number,
  limit: number,
): Promise<{ data: User[]; total: number }> {
  const [data, total] = await this.usersRepository
    .createQueryBuilder('user')
    .skip((page - 1) * limit)
    .take(limit)
    .getManyAndCount();

  return { data, total };
}

// Search
async search(query: string): Promise<User[]> {
  return this.usersRepository
    .createQueryBuilder('user')
    .where('user.name ILIKE :query', { query: `%${query}%` })
    .orWhere('user.email ILIKE :query', { query: `%${query}%` })
    .getMany();
}

// Aggregation
async getUserStats(): Promise<any> {
  return this.usersRepository
    .createQueryBuilder('user')
    .select('COUNT(user.id)', 'totalUsers')
    .addSelect('COUNT(CASE WHEN user.isActive THEN 1 END)', 'activeUsers')
    .getRawOne();
}
```

## Transactions

### Using QueryRunner

```typescript
import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository, DataSource } from "typeorm";
import { User } from "./entities/user.entity";
import { Post } from "./entities/post.entity";

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(Post)
    private postsRepository: Repository<Post>,
    private dataSource: DataSource,
  ) {}

  async createUserWithPosts(
    userData: CreateUserDto,
    postsData: CreatePostDto[],
  ): Promise<User> {
    const queryRunner = this.dataSource.createQueryRunner();

    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Create user
      const user = queryRunner.manager.create(User, userData);
      await queryRunner.manager.save(user);

      // Create posts
      const posts = postsData.map((postData) =>
        queryRunner.manager.create(Post, {
          ...postData,
          author: user,
        }),
      );
      await queryRunner.manager.save(posts);

      await queryRunner.commitTransaction();
      return user;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw err;
    } finally {
      await queryRunner.release();
    }
  }
}
```

### Using Transaction Decorator

```typescript
import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Transactional } from "typeorm-transactional";
import { User } from "./entities/user.entity";

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  @Transactional()
  async transferBalance(
    fromId: number,
    toId: number,
    amount: number,
  ): Promise<void> {
    const fromUser = await this.usersRepository.findOne({
      where: { id: fromId },
    });
    const toUser = await this.usersRepository.findOne({ where: { id: toId } });

    fromUser.balance -= amount;
    toUser.balance += amount;

    await this.usersRepository.save([fromUser, toUser]);
  }
}
```

## Custom Repositories

```typescript
import { Injectable } from "@nestjs/common";
import { DataSource, Repository } from "typeorm";
import { User } from "./entities/user.entity";

@Injectable()
export class UsersRepository extends Repository<User> {
  constructor(private dataSource: DataSource) {
    super(User, dataSource.createEntityManager());
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.findOne({
      where: { email },
      relations: ["roles"],
    });
  }

  async findActiveUsers(): Promise<User[]> {
    return this.createQueryBuilder("user")
      .where("user.isActive = :isActive", { isActive: true })
      .orderBy("user.createdAt", "DESC")
      .getMany();
  }

  async softDelete(id: number): Promise<void> {
    await this.update(id, { deletedAt: new Date() });
  }
}
```

**Register custom repository:**

```typescript
import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { UsersRepository } from "./users.repository";
import { UsersService } from "./users.service";
import { User } from "./entities/user.entity";

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  providers: [UsersRepository, UsersService],
  exports: [UsersRepository],
})
export class UsersModule {}
```

## Migrations

### Generate Migration

```bash
npm run typeorm migration:generate -- -n CreateUsersTable
```

### Create Migration Manually

```typescript
import { MigrationInterface, QueryRunner, Table } from "typeorm";

export class CreateUsersTable1234567890 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: "users",
        columns: [
          {
            name: "id",
            type: "int",
            isPrimary: true,
            isGenerated: true,
            generationStrategy: "increment",
          },
          {
            name: "email",
            type: "varchar",
            isUnique: true,
          },
          {
            name: "name",
            type: "varchar",
          },
          {
            name: "password",
            type: "varchar",
          },
          {
            name: "created_at",
            type: "timestamp",
            default: "now()",
          },
          {
            name: "updated_at",
            type: "timestamp",
            default: "now()",
          },
        ],
      }),
      true,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable("users");
  }
}
```

### Run Migrations

```bash
npm run typeorm migration:run
npm run typeorm migration:revert
```

## Advanced Patterns

### Soft Delete

```typescript
import { Entity, Column, DeleteDateColumn } from "typeorm";

@Entity("users")
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @DeleteDateColumn()
  deletedAt: Date;
}

// Usage
await this.usersRepository.softDelete(id);
await this.usersRepository.restore(id);

// Find including soft-deleted
await this.usersRepository.find({ withDeleted: true });
```

### Optimistic Locking

```typescript
import { Entity, Column, VersionColumn } from "typeorm";

@Entity("products")
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column()
  stock: number;

  @VersionColumn()
  version: number;
}

// TypeORM will throw error if version doesn't match
```

### Listeners and Subscribers

```typescript
import { Entity, Column, BeforeInsert, BeforeUpdate, AfterLoad } from "typeorm";
import * as bcrypt from "bcrypt";

@Entity("users")
export class User {
  @Column()
  password: string;

  private tempPassword: string;

  @AfterLoad()
  private loadTempPassword(): void {
    this.tempPassword = this.password;
  }

  @BeforeInsert()
  @BeforeUpdate()
  async hashPassword(): Promise<void> {
    if (this.password !== this.tempPassword) {
      this.password = await bcrypt.hash(this.password, 10);
    }
  }
}
```

## Performance Optimization

### Indexing

```typescript
import { Entity, Column, Index } from "typeorm";

@Entity("users")
@Index(["email", "isActive"])
export class User {
  @Column()
  @Index()
  email: string;

  @Column()
  @Index()
  isActive: boolean;
}
```

### Query Caching

```typescript
// Cache query results
async findActiveUsers(): Promise<User[]> {
  return this.usersRepository.find({
    where: { isActive: true },
    cache: {
      id: 'active_users',
      milliseconds: 60000, // 1 minute
    },
  });
}

// Clear cache
await this.usersRepository.manager.connection.queryResultCache.remove([
  'active_users',
]);
```

### Batch Operations

```typescript
// Bulk insert
async bulkCreate(users: CreateUserDto[]): Promise<User[]> {
  const entities = this.usersRepository.create(users);
  return this.usersRepository.save(entities);
}

// Bulk update
async bulkUpdate(ids: number[], updates: Partial<User>): Promise<void> {
  await this.usersRepository
    .createQueryBuilder()
    .update(User)
    .set(updates)
    .whereInIds(ids)
    .execute();
}
```

## Best Practices

1. **Always use transactions** for operations affecting multiple tables
2. **Disable synchronize in production** - use migrations instead
3. **Use query builder** for complex queries instead of raw SQL
4. **Index frequently queried columns** for performance
5. **Avoid N+1 queries** by eagerly loading relations when needed
6. **Use pagination** for large result sets
7. **Validate data** at both DTO and entity level
8. **Handle errors** properly with try-catch or filters
9. **Use connection pooling** for better performance
10. **Monitor query performance** with logging in development
