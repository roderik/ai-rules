#!/usr/bin/env bun

/**
 * Analyze query performance and suggest optimizations
 *
 * This script analyzes slow queries and provides recommendations for:
 * - Missing indexes
 * - Unused indexes
 * - Query optimization suggestions
 *
 * Usage:
 *   bun run scripts/analyze-queries.ts
 *
 * Environment variables:
 *   DATABASE_URL - PostgreSQL connection string
 */

import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { sql } from "drizzle-orm";

const DATABASE_URL = process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error("❌ DATABASE_URL environment variable is required");
  process.exit(1);
}

async function main() {
  console.log("🔍 Connecting to database...\n");
  const client = postgres(DATABASE_URL!);
  const db = drizzle(client);

  try {
    // Check if pg_stat_statements is enabled
    const [extension] = await client`
      SELECT * FROM pg_extension WHERE extname = 'pg_stat_statements';
    `;

    if (!extension) {
      console.log("⚠️  pg_stat_statements extension not found. Installing...");
      await client`CREATE EXTENSION IF NOT EXISTS pg_stat_statements;`;
      console.log("✅ pg_stat_statements extension installed\n");
    }

    // Analyze slow queries
    console.log("📊 === SLOW QUERIES ANALYSIS ===\n");
    await analyzeSlowQueries(client);

    // Find missing indexes
    console.log("\n📊 === MISSING INDEXES ANALYSIS ===\n");
    await analyzeMissingIndexes(client);

    // Find unused indexes
    console.log("\n📊 === UNUSED INDEXES ANALYSIS ===\n");
    await analyzeUnusedIndexes(client);

    // Analyze table statistics
    console.log("\n📊 === TABLE STATISTICS ===\n");
    await analyzeTableStats(client);

    console.log("\n✅ Analysis complete!");
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

async function analyzeSlowQueries(client: any) {
  const slowQueries = await client`
    SELECT
      calls,
      total_exec_time::numeric(10,2) as total_time_ms,
      mean_exec_time::numeric(10,2) as avg_time_ms,
      max_exec_time::numeric(10,2) as max_time_ms,
      rows,
      LEFT(query, 100) as query_preview
    FROM pg_stat_statements
    WHERE query NOT LIKE '%pg_stat_statements%'
      AND query NOT LIKE '%information_schema%'
    ORDER BY mean_exec_time DESC
    LIMIT 10;
  `;

  if (slowQueries.length === 0) {
    console.log(
      "✅ No slow queries detected (or pg_stat_statements needs more data)",
    );
    return;
  }

  console.log("Top 10 slowest queries (by average execution time):\n");

  for (const query of slowQueries) {
    console.log(`Query: ${query.query_preview}...`);
    console.log(`  Calls: ${query.calls}`);
    console.log(`  Avg Time: ${query.avg_time_ms}ms`);
    console.log(`  Max Time: ${query.max_time_ms}ms`);
    console.log(`  Total Time: ${query.total_time_ms}ms`);
    console.log(`  Rows: ${query.rows}`);

    // Provide recommendations
    if (query.avg_time_ms > 100) {
      console.log("  ⚠️  RECOMMENDATION: This query is slow (>100ms average)");
      console.log("     - Run EXPLAIN ANALYZE to understand the query plan");
      console.log("     - Check if proper indexes exist");
      console.log("     - Consider query optimization or caching");
    }

    console.log("");
  }
}

async function analyzeMissingIndexes(client: any) {
  const tablesWithSeqScans = await client`
    SELECT
      schemaname,
      tablename,
      seq_scan,
      seq_tup_read,
      idx_scan,
      ROUND((100.0 * seq_tup_read / NULLIF(seq_scan, 0))::numeric, 2) AS avg_seq_tup_read,
      pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size
    FROM pg_stat_user_tables
    WHERE seq_scan > 0
      AND schemaname = 'public'
    ORDER BY seq_tup_read DESC
    LIMIT 10;
  `;

  if (tablesWithSeqScans.length === 0) {
    console.log("✅ No sequential scans detected on large tables");
    return;
  }

  console.log(
    "Tables with high sequential scans (potential missing indexes):\n",
  );

  for (const table of tablesWithSeqScans) {
    console.log(`Table: ${table.schemaname}.${table.tablename}`);
    console.log(`  Sequential Scans: ${table.seq_scan}`);
    console.log(`  Rows Read: ${table.seq_tup_read}`);
    console.log(`  Index Scans: ${table.idx_scan || 0}`);
    console.log(`  Avg Rows per Scan: ${table.avg_seq_tup_read}`);
    console.log(`  Table Size: ${table.table_size}`);

    if (table.idx_scan === 0 || table.seq_scan > table.idx_scan * 2) {
      console.log("  ⚠️  RECOMMENDATION: Consider adding indexes");
      console.log("     - Analyze WHERE clauses in queries using this table");
      console.log("     - Create indexes on frequently filtered columns");
      console.log("     - Check JOIN conditions");
    }

    console.log("");
  }
}

async function analyzeUnusedIndexes(client: any) {
  const unusedIndexes = await client`
    SELECT
      schemaname,
      tablename,
      indexname,
      idx_scan,
      pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
    FROM pg_stat_user_indexes
    WHERE idx_scan = 0
      AND indexrelname NOT LIKE '%_pkey'
      AND schemaname = 'public'
    ORDER BY pg_relation_size(indexrelid) DESC
    LIMIT 10;
  `;

  if (unusedIndexes.length === 0) {
    console.log("✅ No unused indexes detected");
    return;
  }

  console.log("Unused indexes (never scanned):\n");

  for (const index of unusedIndexes) {
    console.log(`Index: ${index.schemaname}.${index.indexname}`);
    console.log(`  Table: ${index.tablename}`);
    console.log(`  Scans: ${index.idx_scan}`);
    console.log(`  Size: ${index.index_size}`);
    console.log("  ⚠️  RECOMMENDATION: Consider dropping this index");
    console.log("     - Verify it's not needed for constraints");
    console.log(
      "     - Check if it was created for a specific query that no longer runs",
    );
    console.log(`     - Drop with: DROP INDEX IF EXISTS ${index.indexname};`);
    console.log("");
  }
}

async function analyzeTableStats(client: any) {
  const tableStats = await client`
    SELECT
      schemaname,
      tablename,
      n_tup_ins AS inserts,
      n_tup_upd AS updates,
      n_tup_del AS deletes,
      n_live_tup AS live_rows,
      n_dead_tup AS dead_rows,
      ROUND((100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0))::numeric, 2) AS dead_pct,
      pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
      last_vacuum,
      last_autovacuum,
      last_analyze,
      last_autoanalyze
    FROM pg_stat_user_tables
    WHERE schemaname = 'public'
    ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
    LIMIT 10;
  `;

  console.log("Table statistics (top 10 by size):\n");

  for (const table of tableStats) {
    console.log(`Table: ${table.schemaname}.${table.tablename}`);
    console.log(`  Total Size: ${table.total_size}`);
    console.log(`  Live Rows: ${table.live_rows}`);
    console.log(`  Dead Rows: ${table.dead_rows} (${table.dead_pct}%)`);
    console.log(`  Operations:`);
    console.log(`    Inserts: ${table.inserts}`);
    console.log(`    Updates: ${table.updates}`);
    console.log(`    Deletes: ${table.deletes}`);
    console.log(`  Last Vacuum: ${table.last_vacuum || "Never"}`);
    console.log(`  Last Analyze: ${table.last_analyze || "Never"}`);

    // Recommendations
    if (table.dead_pct > 20) {
      console.log("  ⚠️  RECOMMENDATION: High dead row percentage");
      console.log(`     - Run: VACUUM ANALYZE ${table.tablename};`);
    }

    if (!table.last_analyze) {
      console.log("  ⚠️  RECOMMENDATION: Statistics never collected");
      console.log(`     - Run: ANALYZE ${table.tablename};`);
    }

    console.log("");
  }
}

main();
