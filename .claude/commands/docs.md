---
description: Write or improve documentation using OpenAI best practices with diagrams and links
argument-hint: [file-pattern]
allowed-tools: Read, Edit, Write, Bash
---

## Files to Document

- Documentation files: !`fd -e md -e mdx`
- Recent changes: !`git diff --name-only HEAD~1..HEAD | grep -E '\.(md|mdx)$'`
- Target files: $ARGUMENTS

## Documentation Writing Task

Apply OpenAI documentation best practices to create/improve documentation:

### Principles

**Make Docs Easy to Skim**

- Split content into sections with informative sentence titles (not abstract nouns)
- Include table of contents for multi-section docs
- Keep paragraphs short with topic sentences that stand alone
- Put key topic words at beginning of sentences
- Place most important information at the top
- Use bullets, tables, and bold text to highlight key information

**Write Well**

- Keep sentences simple, clear, and unambiguous
- Avoid left-branching structures (put context after main point)
- Minimize demonstrative pronouns (this, that) - be specific
- Maintain consistency in style and formatting

**Be Broadly Helpful**

- Write simply - avoid unnecessary technical abbreviations
- Proactively explain potential problems and gotchas
- Use specific, accurate terminology
- Create general, exportable code examples
- Provide broad context when introducing topics

### Visual Communication

**ALWAYS add Mermaid diagrams** when visualizing:

- Architecture and system flows
- Process workflows and decision trees
- Dependency relationships
- State machines and lifecycle

**Use repo's markdown flavor and custom components**:

- Check existing docs to match established patterns
- GitHub: alerts, task lists, mermaid, syntax highlighting
- Fumadocs: callouts, cards, tabs, file trees
- Docusaurus: admonitions, code blocks with titles

### Content Requirements

**Introduce New Concepts**

- Provide brief context before using specialized tools/terms
- Example: "Terraform (infrastructure-as-code tool) provisions cloud resources..."

**Link Third-Party Tools**

- Convert tool mentions to documentation links
- Examples:
  - Terraform → [Terraform](https://developer.hashicorp.com/terraform/docs)
  - React → [React](https://react.dev)
  - Kubernetes → [Kubernetes](https://kubernetes.io/docs)

**Code Examples**

- Show realistic, copy-pastable examples
- Include necessary imports and context
- Explain non-obvious parameters
- Demonstrate common use cases first

### Documentation Types

**README**: Clear purpose statement, quick start, prerequisites
**API Docs**: Parameters with types, example requests/responses, errors
**Guides**: Learning outcomes, logical sections, progress checkpoints
**Architecture**: Overview diagram, component relationships, design decisions

Apply these principles to: ${ARGUMENTS:-all documentation files}
