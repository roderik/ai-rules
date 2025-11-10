#!/usr/bin/env bun

/**
 * Generate TypeScript schema from existing PostgreSQL database
 *
 * This script introspects a PostgreSQL database and generates Drizzle ORM schema files.
 * It's useful when working with existing databases or migrating from other ORMs.
 *
 * Usage:
 *   bun run scripts/generate-schema.ts
 *
 * Environment variables:
 *   DATABASE_URL - PostgreSQL connection string
 *   OUTPUT_DIR - Output directory for schema files (default: ./src/db/schema)
 */

import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { pgTable, pgEnum } from "drizzle-orm/pg-core";
import * as fs from "fs/promises";
import * as path from "path";

const DATABASE_URL = process.env.DATABASE_URL;
const OUTPUT_DIR = process.env.OUTPUT_DIR || "./src/db/schema";

if (!DATABASE_URL) {
  console.error("❌ DATABASE_URL environment variable is required");
  process.exit(1);
}

async function main() {
  console.log("🔍 Connecting to database...");
  const client = postgres(DATABASE_URL!);
  const db = drizzle(client);

  try {
    // Get all tables
    const tables = await client`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
      ORDER BY table_name;
    `;

    console.log(`📋 Found ${tables.length} tables`);

    // Ensure output directory exists
    await fs.mkdir(OUTPUT_DIR, { recursive: true });

    for (const { table_name } of tables) {
      console.log(`\n📝 Generating schema for table: ${table_name}`);

      // Get columns
      const columns = await client`
        SELECT
          column_name,
          data_type,
          column_default,
          is_nullable,
          character_maximum_length,
          numeric_precision,
          numeric_scale
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = ${table_name}
        ORDER BY ordinal_position;
      `;

      // Get primary keys
      const primaryKeys = await client`
        SELECT a.attname AS column_name
        FROM pg_index i
        JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
        WHERE i.indrelid = ${table_name}::regclass
          AND i.indisprimary;
      `;

      // Get foreign keys
      const foreignKeys = await client`
        SELECT
          kcu.column_name,
          ccu.table_name AS foreign_table_name,
          ccu.column_name AS foreign_column_name
        FROM information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
          ON tc.constraint_name = kcu.constraint_name
          AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage AS ccu
          ON ccu.constraint_name = tc.constraint_name
          AND ccu.table_schema = tc.table_schema
        WHERE tc.constraint_type = 'FOREIGN KEY'
          AND tc.table_name = ${table_name};
      `;

      // Generate schema file
      const schemaContent = generateSchemaFile(
        table_name,
        columns,
        primaryKeys,
        foreignKeys,
      );

      const outputPath = path.join(OUTPUT_DIR, `${table_name}.ts`);
      await fs.writeFile(outputPath, schemaContent);

      console.log(`✅ Generated: ${outputPath}`);
    }

    // Generate index file
    const indexContent = tables
      .map(({ table_name }) => `export * from './${table_name}';`)
      .join("\n");

    const indexPath = path.join(OUTPUT_DIR, "index.ts");
    await fs.writeFile(indexPath, indexContent + "\n");

    console.log(`\n✅ Generated index file: ${indexPath}`);
    console.log(`\n🎉 Schema generation complete!`);
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

function generateSchemaFile(
  tableName: string,
  columns: any[],
  primaryKeys: any[],
  foreignKeys: any[],
): string {
  const imports = new Set(["pgTable"]);
  const columnDefinitions: string[] = [];
  const pkColumns = new Set(primaryKeys.map((pk) => pk.column_name));
  const fkMap = new Map(foreignKeys.map((fk) => [fk.column_name, fk]));

  for (const col of columns) {
    const { column_name, data_type, is_nullable, character_maximum_length } =
      col;
    let colDef = "";

    // Map PostgreSQL types to Drizzle types
    switch (data_type) {
      case "integer":
        imports.add("integer");
        colDef = `integer('${column_name}')`;
        break;
      case "bigint":
        imports.add("bigint");
        colDef = `bigint('${column_name}', { mode: 'number' })`;
        break;
      case "smallint":
        imports.add("smallint");
        colDef = `smallint('${column_name}')`;
        break;
      case "serial":
        imports.add("serial");
        colDef = `serial('${column_name}')`;
        break;
      case "text":
        imports.add("text");
        colDef = `text('${column_name}')`;
        break;
      case "character varying":
      case "varchar":
        imports.add("varchar");
        colDef = character_maximum_length
          ? `varchar('${column_name}', { length: ${character_maximum_length} })`
          : `varchar('${column_name}')`;
        break;
      case "boolean":
        imports.add("boolean");
        colDef = `boolean('${column_name}')`;
        break;
      case "timestamp without time zone":
      case "timestamp":
        imports.add("timestamp");
        colDef = `timestamp('${column_name}')`;
        break;
      case "timestamp with time zone":
      case "timestamptz":
        imports.add("timestamp");
        colDef = `timestamp('${column_name}', { withTimezone: true })`;
        break;
      case "date":
        imports.add("date");
        colDef = `date('${column_name}')`;
        break;
      case "numeric":
      case "decimal":
        imports.add("numeric");
        colDef = `numeric('${column_name}')`;
        break;
      case "jsonb":
        imports.add("jsonb");
        colDef = `jsonb('${column_name}')`;
        break;
      case "json":
        imports.add("json");
        colDef = `json('${column_name}')`;
        break;
      case "uuid":
        imports.add("uuid");
        colDef = `uuid('${column_name}')`;
        break;
      default:
        imports.add("text");
        colDef = `text('${column_name}') // TODO: Verify type for ${data_type}`;
    }

    // Add foreign key reference
    if (fkMap.has(column_name)) {
      const fk = fkMap.get(column_name)!;
      colDef += `.references(() => ${fk.foreign_table_name}.${fk.foreign_column_name})`;
    }

    // Add primary key
    if (pkColumns.has(column_name)) {
      colDef += ".primaryKey()";
    }

    // Add not null
    if (is_nullable === "NO") {
      colDef += ".notNull()";
    }

    columnDefinitions.push(`  ${column_name}: ${colDef},`);
  }

  const importsStr = `import { ${Array.from(imports).sort().join(", ")} } from 'drizzle-orm/pg-core';`;

  return `${importsStr}

export const ${tableName} = pgTable('${tableName}', {
${columnDefinitions.join("\n")}
});
`;
}

main();
