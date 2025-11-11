# NestJS Database Integration with MikroORM + MongoDB

## Overview

Comprehensive guide for MikroORM integration with NestJS and MongoDB, covering entity definition, repository patterns, EntityManager usage, queries, transactions, migrations, and best practices.

## Setup and Configuration

### Install Dependencies

```bash
npm install @mikro-orm/core @mikro-orm/nestjs @mikro-orm/mongodb
npm install --save-dev @mikro-orm/cli
```

### Configure MikroORM Module

```typescript
import { Module } from "@nestjs/common";
import { MikroOrmModule } from "@mikro-orm/nestjs";
import { ConfigModule, ConfigService } from "@nestjs/config";

@Module({
  imports: [
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
  ],
})
export class AppModule {}
```

### mikro-orm.config.ts

```typescript
import { defineConfig } from "@mikro-orm/mongodb";
import { Migrator } from "@mikro-orm/migrations-mongodb";
import { SeedManager } from "@mikro-orm/seeder";

export default defineConfig({
  type: "mongo",
  clientUrl: process.env.MONGODB_URI,
  dbName: process.env.DB_NAME,
  entities: ["./dist/**/*.entity.js"],
  entitiesTs: ["./src/**/*.entity.ts"],
  debug: process.env.NODE_ENV === "development",
  extensions: [Migrator, SeedManager],
  migrations: {
    path: "./dist/migrations",
    pathTs: "./src/migrations",
  },
  seeder: {
    path: "./dist/seeders",
    pathTs: "./src/seeders",
  },
});
```

## Entity Definition

### Basic Entity

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
  isActive = true;

  @Property()
  createdAt = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt = new Date();

  constructor(email: string, name: string, password: string) {
    this.email = email;
    this.name = name;
    this.password = password;
  }
}
```

### Entity with Embedded Objects

```typescript
import {
  Embedded,
  Embeddable,
  Entity,
  Property,
  PrimaryKey,
} from "@mikro-orm/core";
import { ObjectId } from "@mikro-orm/mongodb";

@Embeddable()
export class Address {
  @Property()
  street!: string;

  @Property()
  city!: string;

  @Property()
  state!: string;

  @Property()
  zipCode!: string;

  @Property()
  country!: string;
}

@Entity()
export class User {
  @PrimaryKey()
  _id!: ObjectId;

  @Property()
  name!: string;

  @Embedded(() => Address, { nullable: true })
  address?: Address;
}
```

## Entity Relationships

### One-to-Many / Many-to-One

```typescript
import {
  Entity,
  Property,
  PrimaryKey,
  ManyToOne,
  OneToMany,
  Collection,
} from "@mikro-orm/core";
import { ObjectId } from "@mikro-orm/mongodb";

@Entity()
export class User {
  @PrimaryKey()
  _id!: ObjectId;

  @Property()
  name!: string;

  @OneToMany(() => Post, (post) => post.author)
  posts = new Collection<Post>(this);
}

@Entity()
export class Post {
  @PrimaryKey()
  _id!: ObjectId;

  @Property()
  title!: string;

  @Property()
  content!: string;

  @ManyToOne(() => User)
  author!: User;

  @Property()
  createdAt = new Date();
}
```

### Many-to-Many

```typescript
import {
  Entity,
  Property,
  PrimaryKey,
  ManyToMany,
  Collection,
} from "@mikro-orm/core";
import { ObjectId } from "@mikro-orm/mongodb";

@Entity()
export class User {
  @PrimaryKey()
  _id!: ObjectId;

  @Property()
  name!: string;

  @ManyToMany(() => Role, (role) => role.users, { owner: true })
  roles = new Collection<Role>(this);
}

@Entity()
export class Role {
  @PrimaryKey()
  _id!: ObjectId;

  @Property({ unique: true })
  name!: string;

  @ManyToMany(() => User, (user) => user.roles)
  users = new Collection<User>(this);
}
```

### Self-Referencing

```typescript
import {
  Entity,
  Property,
  PrimaryKey,
  ManyToOne,
  OneToMany,
  Collection,
} from "@mikro-orm/core";
import { ObjectId } from "@mikro-orm/mongodb";

@Entity()
export class Category {
  @PrimaryKey()
  _id!: ObjectId;

  @Property()
  name!: string;

  @ManyToOne(() => Category, { nullable: true })
  parent?: Category;

  @OneToMany(() => Category, (category) => category.parent)
  children = new Collection<Category>(this);
}
```

## Repository Operations

### Basic CRUD with Repository

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

  // Create
  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.usersRepository.create(createUserDto);
    await this.usersRepository.persistAndFlush(user);
    return user;
  }

  // Read all
  async findAll(): Promise<User[]> {
    return this.usersRepository.findAll();
  }

  // Read one
  async findOne(id: string): Promise<User> {
    const user = await this.usersRepository.findOne(id);
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }

  // Update
  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id);
    Object.assign(user, updateUserDto);
    await this.usersRepository.flush();
    return user;
  }

  // Delete
  async remove(id: string): Promise<void> {
    const user = await this.findOne(id);
    await this.usersRepository.removeAndFlush(user);
  }
}
```

### Using EntityManager

```typescript
import { Injectable } from "@nestjs/common";
import { EntityManager } from "@mikro-orm/mongodb";
import { User } from "./entities/user.entity";

@Injectable()
export class UsersService {
  constructor(private readonly em: EntityManager) {}

  async create(data: CreateUserDto): Promise<User> {
    const user = this.em.create(User, data);
    await this.em.persistAndFlush(user);
    return user;
  }

  async findAll(): Promise<User[]> {
    return this.em.find(User, {});
  }

  async findOne(id: string): Promise<User> {
    return this.em.findOneOrFail(User, id);
  }
}
```

### Loading Relations

```typescript
// Populate single relation
const user = await this.usersRepository.findOne(id, {
  populate: ["posts"],
});

// Populate multiple relations
const user = await this.usersRepository.findOne(id, {
  populate: ["posts", "roles"],
});

// Populate nested relations
const user = await this.usersRepository.findOne(id, {
  populate: ["posts", "posts.comments", "posts.comments.author"],
});

// Populate all relations
const user = await this.usersRepository.findOne(id, {
  populate: ["*"],
});
```

### Query Filtering

```typescript
// Simple filtering
const activeUsers = await this.usersRepository.find({ isActive: true });

// Multiple conditions (AND)
const users = await this.usersRepository.find({
  isActive: true,
  role: "admin",
});

// OR conditions
const users = await this.usersRepository.find({
  $or: [{ role: "admin" }, { role: "moderator" }],
});

// Comparison operators
const users = await this.usersRepository.find({
  age: { $gte: 18, $lt: 65 },
  createdAt: { $gte: new Date("2024-01-01") },
});

// Array operations
const users = await this.usersRepository.find({
  tags: { $in: ["premium", "verified"] },
});

// Text search (MongoDB)
const users = await this.usersRepository.find({
  $text: { $search: "john" },
});

// Regex search
const users = await this.usersRepository.find({
  email: { $re: ".*@example.com" },
});
```

### Pagination and Sorting

```typescript
// Pagination
const [users, total] = await this.usersRepository.findAndCount(
  { isActive: true },
  {
    limit: 10,
    offset: 0,
    orderBy: { createdAt: "DESC" },
  },
);

// Cursor-based pagination
const users = await this.usersRepository.find(
  { _id: { $gt: lastSeenId } },
  {
    limit: 10,
    orderBy: { _id: "ASC" },
  },
);
```

### Aggregation

```typescript
// Count
const count = await this.usersRepository.count({ isActive: true });

// Aggregation pipeline (MongoDB)
const result = await this.em.aggregate(User, [
  { $match: { isActive: true } },
  { $group: { _id: "$role", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
]);
```

## Transactions

### Using EntityManager fork

```typescript
import { Injectable } from "@nestjs/common";
import { EntityManager } from "@mikro-orm/mongodb";
import { User } from "./entities/user.entity";
import { Post } from "./entities/post.entity";

@Injectable()
export class UsersService {
  constructor(private readonly em: EntityManager) {}

  async createUserWithPosts(
    userData: CreateUserDto,
    postsData: CreatePostDto[],
  ): Promise<User> {
    // Fork the EntityManager for transaction
    return this.em.transactional(async (em) => {
      // Create user
      const user = em.create(User, userData);
      await em.persist(user).flush();

      // Create posts
      const posts = postsData.map((postData) =>
        em.create(Post, { ...postData, author: user }),
      );
      await em.persist(posts).flush();

      return user;
    });
  }
}
```

### Manual Transaction Control

```typescript
async transferCredits(fromId: string, toId: string, amount: number): Promise<void> {
  const em = this.em.fork();

  await em.begin();

  try {
    const fromUser = await em.findOneOrFail(User, fromId);
    const toUser = await em.findOneOrFail(User, toId);

    fromUser.credits -= amount;
    toUser.credits += amount;

    await em.flush();
    await em.commit();
  } catch (error) {
    await em.rollback();
    throw error;
  }
}
```

## Custom Repositories

```typescript
import { EntityRepository } from "@mikro-orm/mongodb";
import { User } from "./entities/user.entity";

export class UsersRepository extends EntityRepository<User> {
  async findByEmail(email: string): Promise<User | null> {
    return this.findOne({ email }, { populate: ["roles"] });
  }

  async findActiveUsers(): Promise<User[]> {
    return this.find(
      { isActive: true },
      {
        orderBy: { createdAt: "DESC" },
      },
    );
  }

  async searchUsers(query: string): Promise<User[]> {
    return this.find({
      $or: [
        { name: { $re: query, $options: "i" } },
        { email: { $re: query, $options: "i" } },
      ],
    });
  }

  async softDelete(id: string): Promise<void> {
    const user = await this.findOneOrFail(id);
    user.isActive = false;
    user.deletedAt = new Date();
    await this.flush();
  }
}
```

**Register custom repository:**

```typescript
import { Module } from "@nestjs/common";
import { MikroOrmModule } from "@mikro-orm/nestjs";
import { User } from "./entities/user.entity";
import { UsersRepository } from "./users.repository";
import { UsersService } from "./users.service";

@Module({
  imports: [
    MikroOrmModule.forFeature({
      entities: [User],
      customRepositories: {
        User: UsersRepository,
      },
    }),
  ],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

## Migrations

### Generate Migration

```bash
npx mikro-orm migration:create
```

### Create Migration Manually

```typescript
import { Migration } from "@mikro-orm/migrations-mongodb";

export class Migration20240101120000 extends Migration {
  async up(): Promise<void> {
    this.getCollection("users").createIndex({ email: 1 }, { unique: true });
    this.getCollection("users").createIndex({ createdAt: -1 });
  }

  async down(): Promise<void> {
    this.getCollection("users").dropIndex("email_1");
    this.getCollection("users").dropIndex("createdAt_-1");
  }
}
```

### Run Migrations

```bash
npx mikro-orm migration:up       # Run pending migrations
npx mikro-orm migration:down     # Revert last migration
npx mikro-orm migration:list     # List all migrations
```

## Seeders

### Create Seeder

```typescript
import { EntityManager } from "@mikro-orm/mongodb";
import { Seeder } from "@mikro-orm/seeder";
import { User } from "../entities/user.entity";

export class UserSeeder extends Seeder {
  async run(em: EntityManager): Promise<void> {
    const users = [
      em.create(User, {
        email: "admin@example.com",
        name: "Admin User",
        password: "hashed_password",
        role: "admin",
      }),
      em.create(User, {
        email: "user@example.com",
        name: "Regular User",
        password: "hashed_password",
        role: "user",
      }),
    ];

    await em.persistAndFlush(users);
  }
}
```

### Run Seeders

```bash
npx mikro-orm seeder:run          # Run all seeders
npx mikro-orm seeder:run --class=UserSeeder  # Run specific seeder
```

## Advanced Patterns

### Soft Delete

```typescript
import { Entity, Property, Filter } from "@mikro-orm/core";
import { ObjectId } from "@mikro-orm/mongodb";

@Entity()
@Filter({ name: "active", cond: { deletedAt: null }, default: true })
export class User {
  @PrimaryKey()
  _id!: ObjectId;

  @Property()
  name!: string;

  @Property({ nullable: true })
  deletedAt?: Date;
}

// Usage
const activeUsers = await this.usersRepository.findAll(); // Only active users
const allUsers = await this.usersRepository.findAll({
  filters: { active: false },
}); // All users
```

### Virtual Properties

```typescript
import { Entity, Property } from "@mikro-orm/core";

@Entity()
export class User {
  @Property()
  firstName!: string;

  @Property()
  lastName!: string;

  @Property({ persist: false })
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }
}
```

### Lifecycle Hooks

```typescript
import { Entity, Property, BeforeCreate, BeforeUpdate } from "@mikro-orm/core";
import * as bcrypt from "bcrypt";

@Entity()
export class User {
  @Property({ hidden: true })
  password!: string;

  @BeforeCreate()
  @BeforeUpdate()
  async hashPassword() {
    if (this.password && !this.password.startsWith("$2")) {
      this.password = await bcrypt.hash(this.password, 10);
    }
  }
}
```

### Subscribers (Event Listeners)

```typescript
import { EventArgs, EventSubscriber, Subscriber } from "@mikro-orm/core";
import { User } from "./entities/user.entity";

@Subscriber()
export class UserSubscriber implements EventSubscriber<User> {
  getSubscribedEntities() {
    return [User];
  }

  async afterCreate(args: EventArgs<User>): Promise<void> {
    console.log(`User ${args.entity.email} was created`);
    // Send welcome email
  }

  async afterUpdate(args: EventArgs<User>): Promise<void> {
    console.log(`User ${args.entity.email} was updated`);
  }
}
```

## Performance Optimization

### Indexing

```typescript
import { Entity, Property, Index, Unique } from "@mikro-orm/core";

@Entity()
@Index({ properties: ["email", "isActive"] })
export class User {
  @Property()
  @Unique()
  email!: string;

  @Property()
  @Index()
  isActive!: boolean;

  @Property()
  @Index()
  createdAt = new Date();
}
```

### Query Optimization

```typescript
// Use select to fetch only needed fields
const users = await this.usersRepository.find(
  { isActive: true },
  { fields: ["name", "email"] },
);

// Use pagination
const [users, total] = await this.usersRepository.findAndCount(
  {},
  {
    limit: 20,
    offset: 0,
  },
);

// Use populate strategically
const users = await this.usersRepository.find(
  {},
  {
    populate: ["posts"], // Only populate what you need
    populateWhere: { posts: { published: true } }, // Filter populated entities
  },
);
```

### Batch Operations

```typescript
// Bulk insert
const users = userDtos.map((dto) => this.usersRepository.create(dto));
await this.usersRepository.persistAndFlush(users);

// Bulk update (MongoDB)
await this.em.nativeUpdate(User, { role: "user" }, { isActive: true });

// Bulk delete
await this.em.nativeDelete(User, { isActive: false });
```

## Best Practices

1. **Use EntityManager.fork() for transactions** to ensure proper isolation
2. **Always call flush()** after making changes to persist them
3. **Use populate wisely** to avoid N+1 queries
4. **Leverage MongoDB indexes** for frequently queried fields
5. **Use filters** for soft deletes and tenant isolation
6. **Implement custom repositories** for complex queries
7. **Use migrations** in production, not schema synchronization
8. **Test with in-memory MongoDB** using mongodb-memory-server
9. **Use RequestContext** in NestJS for proper request isolation
10. **Monitor query performance** with debug mode during development

## MongoDB-Specific Features

### GridFS for File Storage

```typescript
import { GridFSBucket } from "mongodb";
import { EntityManager } from "@mikro-orm/mongodb";

@Injectable()
export class FilesService {
  private gridFSBucket: GridFSBucket;

  constructor(private readonly em: EntityManager) {
    this.gridFSBucket = new GridFSBucket(this.em.getConnection().getDb());
  }

  async uploadFile(file: Express.Multer.File): Promise<string> {
    const uploadStream = this.gridFSBucket.openUploadStream(file.originalname);
    uploadStream.end(file.buffer);

    return new Promise((resolve, reject) => {
      uploadStream.on("finish", () => resolve(uploadStream.id.toString()));
      uploadStream.on("error", reject);
    });
  }
}
```

### Text Search

```typescript
// Create text index
@Entity()
@Index({ properties: ["title", "content"], type: "text" })
export class Article {
  @Property()
  title!: string;

  @Property()
  content!: string;
}

// Search
const articles = await this.articlesRepository.find({
  $text: { $search: "typescript nestjs" },
});
```

### Geospatial Queries

```typescript
import { Entity, Property, Index } from "@mikro-orm/core";

@Entity()
export class Location {
  @Property()
  name!: string;

  @Property()
  @Index({ type: "2dsphere" })
  coordinates!: {
    type: "Point";
    coordinates: [number, number]; // [longitude, latitude]
  };
}

// Find nearby locations
const nearbyLocations = await this.locationsRepository.find({
  coordinates: {
    $near: {
      $geometry: {
        type: "Point",
        coordinates: [-73.97, 40.77],
      },
      $maxDistance: 5000, // meters
    },
  },
});
```
