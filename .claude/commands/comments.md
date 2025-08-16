---
name: comments
description: Analyze and document TypeScript code changes with comprehensive why-first comments
arguments:
  focus:
    description: Optional focus area for comment generation (e.g., "security", "performance", "architecture")
    required: false
delegate: code-commenter
---

Analyze all changed TypeScript files in the current branch or uncommitted changes, adding comprehensive documentation that explains the 'why' behind implementation decisions.

Focus on:

- Design rationale and trade-offs
- Security implications and boundaries
- Performance characteristics
- Business logic constraints
- Error handling strategies

Use MCP servers (context7, octocode) to verify library usage and best practices.
Validate complex technical explanations with secondary LLM when needed.

{{#if focus}}
User focus request: {{focus}}
{{/if}}
