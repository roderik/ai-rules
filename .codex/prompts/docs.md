Write or improve documentation that puts useful information inside readers' heads.

## Principles

### Make Docs Easy to Skim

- Split content into sections with **informative sentence titles** (not abstract nouns)
  - Good: "Installation requires Node.js 18+"
  - Bad: "Requirements"
- Include table of contents for multi-section docs
- Keep paragraphs short with topic sentences that stand alone
- Put key topic words at beginning of sentences
- Place most important information at the top
- Use bullets, tables, and bold text to highlight key information

### Write Well

- Keep sentences simple, clear, and unambiguous
- Avoid left-branching structures (put context after main point)
- Minimize demonstrative pronouns (this, that) - be specific
- Maintain consistency in style and formatting
- Don't tell readers what they think or should do

### Be Broadly Helpful

- Write simply - avoid unnecessary technical abbreviations
- Proactively explain potential problems and gotchas
- Use specific, accurate terminology
- Create general, exportable code examples
- Prioritize documentation by user value
- Avoid teaching bad practices
- Provide broad context when introducing topics

## Visual Communication

### Diagrams

- **ALWAYS add Mermaid diagrams** when visualizing:
  - Architecture and system flows
  - Process workflows and decision trees
  - Dependency relationships
  - State machines and lifecycle
- A diagram says more than a thousand words
- Use appropriate diagram types:
  ```mermaid
  graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action]
    B -->|No| D[Alternative]
  ```

### Documentation Tooling

- Use the repo's markdown flavor and custom components:
  - **GitHub**: alerts, task lists, mermaid, syntax highlighting
  - **Fumadocs**: callouts, cards, tabs, file trees
  - **Docusaurus**: admonitions, code blocks with titles
  - **Nextra**: cards, steps, tabs
- Check existing docs to match the established patterns

## Content Structure

### Introduce New Concepts

- Before using specialized tools/terms, provide brief context
- Link unfamiliar concepts to reader's existing knowledge
- Example: "Terraform (infrastructure-as-code tool) provisions cloud resources..."

### Link Third-Party Tools

- Convert tool mentions to documentation links
- Examples:
  - Terraform → [Terraform](https://developer.hashicorp.com/terraform/docs)
  - React → [React](https://react.dev)
  - Kubernetes → [Kubernetes](https://kubernetes.io/docs)
- Use official documentation URLs

### Code Examples

- Show realistic, copy-pastable examples
- Include necessary imports and context
- Explain non-obvious parameters
- Demonstrate common use cases first

## Documentation Types

### README

- Clear project purpose statement at top
- Quick start section with minimal steps
- Link to detailed docs for complex topics
- Include prerequisites and installation

### API Documentation

- Document all parameters with types and defaults
- Show example requests/responses
- List possible errors and how to handle them
- Group related endpoints logically

### Guides/Tutorials

- State learning outcomes at start
- Break into logical sections with clear titles
- Provide checkpoints to verify progress
- Link to related concepts and next steps

### Architecture Docs

- Start with high-level overview diagram
- Explain key components and their relationships
- Document design decisions and trade-offs
- Show data flow and lifecycle

## Exit Criteria

- Content is skimmable with clear section titles
- Diagrams visualize complex concepts
- Third-party tools are linked
- New concepts are introduced
- Examples are realistic and complete
- Writing is clear and concise
