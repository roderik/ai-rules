---
name: rr-temporal
description: Comprehensive guidance for building durable, fault-tolerant workflows with Temporal and TypeScript. Use when implementing workflow orchestration, distributed systems, long-running processes, saga patterns, or durable execution. Also triggers when working with Temporal TypeScript files (.ts), files importing from @temporalio packages, workflow/activity definitions, or worker configurations. Example triggers: "Create Temporal workflow", "Implement saga pattern", "Set up Temporal worker", "Add activity with retry", "Handle workflow signals", "Use continueAsNew for long-running workflow"
---

# Temporal TypeScript SDK

Build durable, fault-tolerant distributed applications with Temporal. Workflows survive crashes, restarts, and infrastructure failures through event sourcing and deterministic replay.

## When to Use This Skill

Automatically activate when:

- Working with Temporal project files (`workflows/`, `activities/`, `worker.ts`)
- User mentions Temporal, durable execution, or workflow orchestration
- Implementing long-running business processes, sagas, or state machines
- Using decorators/functions like `proxyActivities`, `defineSignal`, `defineQuery`
- Building retry logic, compensation patterns, or distributed transactions
- Files import from `@temporalio/workflow`, `@temporalio/activity`, `@temporalio/client`, `@temporalio/worker`

## Core Concepts

**Workflow**: Deterministic function that orchestrates Activities and other Workflows. Survives failures through replay.

**Activity**: Non-deterministic code (I/O, external APIs, databases). Automatically retried on failure.

**Worker**: Process that executes Workflows and Activities by polling Task Queues.

**Task Queue**: Named queue connecting Clients to Workers. Enables routing and load balancing.

**Signal**: Async message to a running Workflow (fire-and-forget).

**Query**: Sync read-only request to get Workflow state.

**Update**: Sync request that can modify Workflow state and return a result.

## Critical Rules

### Serialization Safety

All data passed between Workflows and Activities must be serializable. Class instances, functions, and complex objects with methods will fail.

```typescript
// BAD: Class instance with methods
class Order {
  constructor(public id: string) {}
  process() {
    /* ... */
  }
}
await activity(new Order("123")); // FAILS

// GOOD: Plain objects only
interface OrderInput {
  id: string;
  items: string[];
}
await activity({ id: "123", items: ["a", "b"] }); // Works
```

**Use SuperJSON for serialization** when complex types are needed.

### No Dynamic Imports in Workflows

Avoid dynamic imports (`import()`) in Workflows as they're non-deterministic.

```typescript
// BAD: Dynamic import
const module = await import(`./handlers/${type}`);

// GOOD: Static imports with conditional logic
import { handlerA, handlerB } from "./handlers";
const handler = type === "a" ? handlerA : handlerB;
```

### Workflow Determinism Requirements

Workflows must be deterministic for replay. Never use:

- `Date.now()` or `new Date()` - use `Workflow.now()` instead
- `Math.random()` - use `uuid4()` from `@temporalio/workflow`
- Network calls - use Activities
- File system access - use Activities
- Global mutable state
- Non-deterministic iteration (e.g., `Object.keys()` order not guaranteed)

## Development Workflow

### 1. Plan Phase

**Before making changes:**

- [ ] Identify what needs to be a Workflow vs Activity
- [ ] Design failure modes and compensation logic
- [ ] Plan idempotency keys for Activities
- [ ] Consider long-running workflow history limits
- [ ] Define signals, queries, and updates needed

### 2. Project Structure

```
src/
├── workflows/
│   ├── index.ts          # Export all workflows
│   └── order.workflow.ts # One workflow per file
├── activities/
│   ├── index.ts          # Export all activities
│   ├── payment.ts        # One activity per file
│   ├── inventory.ts
│   └── notification.ts
├── shared/
│   └── types.ts          # Shared interfaces
├── worker.ts             # Worker configuration
└── client.ts             # Client for starting workflows
```

### 3. Validate Phase (MANDATORY)

After changes:

- [ ] Run type checking: `bun tsc --noEmit`
- [ ] Run tests with time-skipping environment
- [ ] Verify workflow determinism (replay tests)
- [ ] Check activity retry policies are appropriate
- [ ] Test signal/query handlers
- [ ] Verify error handling and compensation

## Quick Start

```bash
# Install
bun add @temporalio/client @temporalio/worker @temporalio/workflow @temporalio/activity

# Start local server
temporal server start-dev
```

## Core Patterns

### Activity Definition

**Keep activities focused and granular.** Export many small functions that each handle a small piece instead of larger functions with multiple steps. Each activity in its own file.

```typescript
// activities/payment.ts
import { log } from "@temporalio/activity";

interface ChargeInput {
  orderId: string;
  amount: number;
  currency: string;
}

export async function chargePayment(input: ChargeInput): Promise<string> {
  log.info("Charging payment", { orderId: input.orderId });

  const response = await fetch("https://api.stripe.com/v1/charges", {
    method: "POST",
    body: JSON.stringify(input),
  });

  if (!response.ok) {
    throw new Error(`Payment failed: ${response.statusText}`);
  }

  const result = await response.json();
  return result.chargeId;
}

export async function refundPayment(chargeId: string): Promise<void> {
  log.info("Refunding payment", { chargeId });
  // Compensation logic
}
```

**Prefer a single object as an argument** over multiple arguments for better extensibility.

### Workflow with Signals, Queries, and Updates

```typescript
// workflows/order.workflow.ts
import {
  proxyActivities,
  defineSignal,
  defineQuery,
  defineUpdate,
  setHandler,
  condition,
  sleep,
  ApplicationFailure,
} from "@temporalio/workflow";
import type * as activities from "../activities";

const { chargePayment, refundPayment, reserveInventory, sendNotification } =
  proxyActivities<typeof activities>({
    startToCloseTimeout: "5 minutes",
    retry: {
      initialInterval: "1s",
      maximumInterval: "60s",
      backoffCoefficient: 2,
      maximumAttempts: 5,
    },
  });

// Define interactions
export const addItemSignal = defineSignal<[string]>("addItem");
export const cancelSignal = defineSignal("cancel");
export const getStatusQuery = defineQuery<OrderStatus>("getStatus");
export const updatePriorityUpdate = defineUpdate<string, [number]>(
  "updatePriority",
);

interface OrderInput {
  orderId: string;
  items: string[];
  customerId: string;
}

type OrderStatus = "pending" | "processing" | "completed" | "cancelled";

export async function orderWorkflow(input: OrderInput): Promise<string> {
  let items = [...input.items];
  let status: OrderStatus = "pending";
  let cancelled = false;
  let priority = 1;

  // Signal handlers
  setHandler(addItemSignal, (item: string) => {
    if (status === "pending") {
      items.push(item);
    }
  });

  setHandler(cancelSignal, () => {
    cancelled = true;
  });

  // Query handler (must be synchronous)
  setHandler(getStatusQuery, () => status);

  // Update handler with validation
  setHandler(
    updatePriorityUpdate,
    async (newPriority: number) => {
      const old = priority;
      priority = newPriority;
      await sendNotification({
        type: "priority_changed",
        orderId: input.orderId,
        from: old,
        to: newPriority,
      });
      return `Priority updated from ${old} to ${newPriority}`;
    },
    {
      validator: (newPriority: number) => {
        if (newPriority < 1 || newPriority > 10) {
          throw ApplicationFailure.nonRetryable("Priority must be 1-10");
        }
      },
    },
  );

  // Wait for confirmation or cancellation
  status = "pending";
  const confirmed = await condition(
    () => cancelled || items.length > 0,
    "1 hour",
  );

  if (cancelled || !confirmed) {
    status = "cancelled";
    return "Order cancelled";
  }

  // Process order
  status = "processing";

  try {
    await reserveInventory({ orderId: input.orderId, items });
    await chargePayment({
      orderId: input.orderId,
      amount: items.length * 100,
      currency: "USD",
    });
    await sendNotification({ type: "order_confirmed", orderId: input.orderId });

    status = "completed";
    return `Order ${input.orderId} completed with ${items.length} items`;
  } catch (error) {
    status = "cancelled";
    throw error;
  }
}
```

### Worker Configuration

```typescript
// worker.ts
import { Worker, NativeConnection } from "@temporalio/worker";
import * as activities from "./activities";

async function run() {
  const connection = await NativeConnection.connect({
    address: process.env.TEMPORAL_ADDRESS || "localhost:7233",
  });

  const worker = await Worker.create({
    connection,
    namespace: process.env.TEMPORAL_NAMESPACE || "default",
    taskQueue: "orders",
    workflowsPath: require.resolve("./workflows"),
    activities,

    // Concurrency tuning
    maxConcurrentActivityTaskExecutions: 100,
    maxConcurrentWorkflowTaskExecutions: 100,
    maxCachedWorkflows: 200,

    // Graceful shutdown
    shutdownGraceTime: "30s",
  });

  // Handle shutdown signals
  process.on("SIGTERM", () => worker.shutdown());
  process.on("SIGINT", () => worker.shutdown());

  await worker.run();
}

run().catch(console.error);
```

### Client Usage

```typescript
// client.ts
import { Client, Connection } from "@temporalio/client";
import { orderWorkflow, addItemSignal, getStatusQuery } from "./workflows";

async function main() {
  const connection = await Connection.connect({
    address: process.env.TEMPORAL_ADDRESS || "localhost:7233",
  });

  const client = new Client({ connection });

  // Start workflow (fire-and-forget)
  const handle = await client.workflow.start(orderWorkflow, {
    taskQueue: "orders",
    workflowId: `order-${Date.now()}`,
    args: [{ orderId: "ORD-123", items: ["item1"], customerId: "CUST-1" }],
    workflowExecutionTimeout: "24 hours",
  });

  console.log(`Started workflow: ${handle.workflowId}`);

  // Signal the workflow
  await handle.signal(addItemSignal, "item2");

  // Query the workflow
  const status = await handle.query(getStatusQuery);
  console.log(`Status: ${status}`);

  // Wait for result
  const result = await handle.result();
  console.log(`Result: ${result}`);
}
```

### Long-Running Workflows with continueAsNew

For processes spanning days/weeks, use `continueAsNew` to manage history size.

```typescript
import { continueAsNew, sleep, Workflow } from "@temporalio/workflow";

interface MonitorState {
  processedCount: number;
  lastCheckpoint: string;
  config: MonitorConfig;
}

const HISTORY_THRESHOLD = 10_000; // Events, not time-based

export async function monitoringWorkflow(state: MonitorState): Promise<never> {
  // Re-register signal handlers immediately after continueAsNew
  setHandler(updateConfigSignal, (newConfig) => {
    state.config = { ...state.config, ...newConfig };
  });

  while (true) {
    // Process work
    await processMetrics(state.config);
    state.processedCount++;
    state.lastCheckpoint = new Date().toISOString();

    await sleep("1 hour");

    // Check history length, not iterations
    if (Workflow.historyLength > HISTORY_THRESHOLD) {
      // Pass complete current state
      await continueAsNew<typeof monitoringWorkflow>(state);
    }
  }
}
```

**Key points:**

- Schedule `continueAsNew` based on event count (~10K events), not time
- Re-register signal handlers immediately in new execution
- Pass complete state as argument
- Use fallback pattern: `if (Workflow.historyLength > THRESHOLD) await continueAsNew(currentState)`

### Sleep vs Absolute Time

Prefer explicit `sleep` over absolute timestamps to avoid timezone issues.

```typescript
// BAD: Absolute time with timezone issues
const deadline = new Date("2024-12-25T09:00:00Z");
await condition(() => false, deadline);

// GOOD: Explicit sleep with cancellation via signal
let cancelled = false;
setHandler(cancelWaitSignal, () => {
  cancelled = true;
});

const waitComplete = await condition(
  () => cancelled,
  "7 days", // Clear duration
);

if (!cancelled) {
  await processScheduledTask();
}
```

### Child Workflows

```typescript
import {
  startChild,
  executeChild,
  ParentClosePolicy,
  ChildWorkflowFailure,
} from "@temporalio/workflow";

export async function parentWorkflow(items: string[]): Promise<void> {
  const childHandles = [];

  // Start children in parallel
  for (const item of items) {
    const handle = await startChild(itemWorkflow, {
      workflowId: `item-${item}`,
      args: [item],
      parentClosePolicy: ParentClosePolicy.PARENT_CLOSE_POLICY_ABANDON,
    });
    childHandles.push(handle);
  }

  // Wait for all with error handling
  const results = await Promise.allSettled(
    childHandles.map(async (handle) => {
      try {
        return await handle.result();
      } catch (error) {
        if (error instanceof ChildWorkflowFailure) {
          // Inspect cause to differentiate failure types
          console.log(`Child failed: ${error.cause}`);
        }
        throw error;
      }
    }),
  );
}
```

### Saga Pattern with Compensation

```typescript
interface SagaStep<T> {
  action: () => Promise<T>;
  compensate: (result: T) => Promise<void>;
}

export async function bookingWorkflow(booking: BookingInput): Promise<string> {
  const completedSteps: Array<() => Promise<void>> = [];

  try {
    // Step 1: Reserve flight
    const flightReservation = await reserveFlight(booking.flight);
    completedSteps.push(() => cancelFlightReservation(flightReservation.id));

    // Step 2: Reserve hotel
    const hotelReservation = await reserveHotel(booking.hotel);
    completedSteps.push(() => cancelHotelReservation(hotelReservation.id));

    // Step 3: Charge payment
    const chargeId = await chargePayment(booking.payment);
    completedSteps.push(() => refundPayment(chargeId));

    // Step 4: Confirm all
    await confirmFlight(flightReservation.id);
    await confirmHotel(hotelReservation.id);

    return `Booking confirmed: ${flightReservation.id}, ${hotelReservation.id}`;
  } catch (error) {
    // Compensate in reverse order
    for (const compensate of completedSteps.reverse()) {
      try {
        await compensate();
      } catch (compensateError) {
        // Log but continue compensating
        console.error("Compensation failed:", compensateError);
      }
    }
    throw error;
  }
}
```

### Local Activities for Low-Latency

```typescript
import { proxyLocalActivities, proxyActivities } from "@temporalio/workflow";
import type * as activities from "./activities";

// Local activities for quick operations (no server round-trip)
const { validateInput, generateId } = proxyLocalActivities<typeof activities>({
  startToCloseTimeout: "2 seconds",
  localRetryThreshold: "30 seconds",
});

// Regular activities for longer operations
const { processData } = proxyActivities<typeof activities>({
  startToCloseTimeout: "5 minutes",
});

export async function quickValidationWorkflow(data: unknown): Promise<string> {
  // Fast local validation
  const isValid = await validateInput(data);
  if (!isValid) {
    throw ApplicationFailure.nonRetryable("Invalid input");
  }

  // Generate ID locally
  const id = await generateId();

  // Heavy processing via regular activity
  return await processData(id, data);
}
```

## Testing

### Time-Skipping Test Environment

```typescript
import { TestWorkflowEnvironment } from "@temporalio/testing";
import { Worker } from "@temporalio/worker";
import { orderWorkflow, addItemSignal, getStatusQuery } from "./workflows";
import * as activities from "./activities";

describe("Order Workflow", () => {
  let testEnv: TestWorkflowEnvironment;

  beforeAll(async () => {
    testEnv = await TestWorkflowEnvironment.createTimeSkipping();
  });

  afterAll(async () => {
    await testEnv.teardown();
  });

  it("completes order successfully", async () => {
    const worker = await Worker.create({
      connection: testEnv.nativeConnection,
      taskQueue: "test",
      workflowsPath: require.resolve("./workflows"),
      activities,
    });

    await worker.runUntil(async () => {
      const handle = await testEnv.client.workflow.start(orderWorkflow, {
        taskQueue: "test",
        workflowId: "test-order-1",
        args: [{ orderId: "order-1", items: ["item1"], customerId: "cust-1" }],
      });

      // Query status
      const status = await handle.query(getStatusQuery);
      expect(status).toBe("pending");

      // Signal to add item
      await handle.signal(addItemSignal, "item2");

      // Time advances automatically - no real wait
      const result = await handle.result();
      expect(result).toContain("completed");
    });
  });
});
```

### Activity Testing with Mocks

```typescript
import { MockActivityEnvironment } from "@temporalio/testing";
import { processItems } from "./activities";

describe("Activities", () => {
  it("processes items with heartbeats", async () => {
    const env = new MockActivityEnvironment();
    const items = Array.from({ length: 100 }, (_, i) => `item-${i}`);

    const result = await env.run(processItems, items);
    expect(result).toBe(100);
  });

  it("handles cancellation", async () => {
    const env = new MockActivityEnvironment();
    const items = Array.from({ length: 1000 }, (_, i) => `item-${i}`);

    const promise = env.run(processItems, items);
    setTimeout(() => env.cancel("test"), 50);

    await expect(promise).rejects.toThrow();
  });
});
```

## Versioning and Patching

```typescript
import { patched, deprecatePatch } from "@temporalio/workflow";

export async function versionedWorkflow(input: string): Promise<string> {
  // Version workflow with patches for backward compatibility
  if (patched("v2-processor")) {
    // New code path
    return await processV2(input);
  } else {
    // Old code path for replay of existing workflows
    return await processV1(input);
  }
}

// After all old workflows complete, remove the patch
export async function migratedWorkflow(input: string): Promise<string> {
  deprecatePatch("v2-processor");
  return await processV2(input);
}
```

## Schedules

```typescript
const client = new Client();

// Create a schedule
await client.schedule.create({
  scheduleId: "daily-report",
  spec: {
    cronExpressions: ["0 9 * * *"], // Daily at 9 AM
  },
  action: {
    type: "startWorkflow",
    workflowType: "generateReportWorkflow",
    taskQueue: "reports",
    args: [{ reportType: "daily" }],
  },
  policies: {
    overlap: "SKIP", // Skip if previous still running
    catchupWindow: "1 day",
  },
});

// Manage schedule
const handle = client.schedule.getHandle("daily-report");
await handle.pause("Maintenance");
await handle.trigger({ overlap: "ALLOW_ALL" });
await handle.unpause();
await handle.delete();
```

## Best Practices Summary

### Workflows

- Keep workflows deterministic - no I/O, no randomness, no wall-clock time
- Use signals for async input, queries for sync state reads, updates for sync mutations
- Store execution plan in workflow variables, not activity results
- Use `continueAsNew` for long-running workflows (~10K events threshold)
- Handle `ChildWorkflowFailure` and inspect `cause` for child workflow errors

### Activities

- One activity per file, single object argument
- Keep activities focused and granular
- Use heartbeats for long-running activities
- Implement idempotency for retry safety
- Use appropriate retry policies per activity type

### General

- Use SuperJSON for complex type serialization
- Test with time-skipping environment
- Use replay testing for determinism verification
- Monitor workflow history length in production

## Resources

- [Temporal Docs](https://docs.temporal.io/)
- [TypeScript SDK Guide](https://docs.temporal.io/develop/typescript)
- [Samples Repository](https://github.com/temporalio/samples-typescript)
- [API Reference](https://typescript.temporal.io/)
