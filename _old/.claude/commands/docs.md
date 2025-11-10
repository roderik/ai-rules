---
description: Craft or enhance documentation to efficiently impart useful knowledge to readers.
---

# Role and Objective
Craft or enhance documentation to efficiently impart useful knowledge to readers. Tailor content to the user's needs and context, focusing on `$FOCUS_AREA` if specified.
Begin with a concise checklist (3–7 conceptual bullets) outlining the major steps or sections before drafting or enhancing any documentation.
# Instructions
Follow these core principles:
## Principles
### Make Documentation Easy to Skim
- **Descriptive section headings:** Use clear, informative, sentence-style titles (avoid one-word or abstract titles). Example: Good – "Installation requires Node.js 18+", Bad – "Requirements".
- **Provide an overview:** For longer documents, include a Table of Contents or overview section to aid navigation.
- **Lead with summary sentences:** Start each section with 1–2 sentences summarizing the main point, followed by details.
- **Leverage lists and tables:** Use bullet points or tables to present lists, steps, or comparisons. This breaks up dense text and highlights key information.
- **Front-load important info:** Place key points at the start of paragraphs. Keep paragraphs short (3–5 sentences) and focused.
### Write Well
- **Use simple, clear language:** Favor short, unambiguous sentences and common words over jargon.
- **Avoid left-branching clauses:** State main ideas first, then provide context.
- **Be specific with references:** Clarify words like "this" or "that" (e.g., "this example," "that process").
- **Maintain consistent style:** Keep a uniform tone and formatting (e.g., second or third person, heading capitalization).
- **Don’t dictate thoughts:** Provide information and options without directing what the reader should think.
### Be Broadly Helpful
- **Assume varied audience levels:** Write for both non-technical stakeholders and engineers. Explain or link to definitions for acronyms or niche terms upon first use.
- **Avoid unnecessary tech slang:** Use standard terminology and expand acronyms at first mention.
- **Anticipate problems:** Proactively highlight common pitfalls and their solutions.
- **Prefer correct solutions:** Recommend best practices; flag hacks or workarounds as such.
- **Provide context and rationale:** Briefly explain why a concept matters or how it fits into the bigger picture.
### Visual Communication
- **Use diagrams for complexity:** Always include Mermaid diagrams for complex processes or architectures. Diagrams should:
- Illustrate architecture, workflows, dependencies, or state machines
- Stay simple and focused on a single idea
- Use the proper diagram type (e.g., flowchart for sequences)
- Example Mermaid:
```mermaid
graph TD
A[Start] --> B{Decision}
B -->|Yes| C[Action]
B -->|No| D[Alternative]
```
- **Verify diagram rendering:** Ensure that diagrams render correctly in the delivered output.
### Documentation Tooling
- **Use supported markdown features:** Leverage platform capabilities (e.g., GitHub-flavored Markdown, Mermaid diagrams, note callouts).
- **Use custom components where available:** For example, tabs, expandable sections, or cards can enhance clarity if supported.
- **Match established style:** Consistency with existing docs/components is essential.
- **Check rendering:** Ensure all complex elements render correctly in the final output.
### Content Structure
#### Introducing New Concepts
- **Provide context first:** Briefly introduce specialized terms before using them (e.g., "Terraform, an infrastructure-as-code tool...").
- **Build on existing knowledge:** Relate new concepts to familiar ideas, using analogies where helpful.
- **Link to definitions or docs:** Link specialized or external topics/tools to their official documentation on first mention.
- **Don't assume prior steps:** Remind readers of prerequisites if part of a sequence or list necessary setup.
#### Third-Party Tools
- **Use official references/links:** Link all third-party tech to their home page or official documentation (e.g., Terraform → Terraform Documentation).
- **Cite authoritative sources:** Use well-known authorities for external definitions (MDN, MSDN, RFCs, etc.).
- **Explain relevance:** Briefly state why a third-party tool is important to your documentation.
### Core Sections
Structure documentation into **three main sections** in line with the Diátaxis framework:
#### Guides
- **Purpose:** Onboarding, conceptual framing, step-by-step walkthroughs for newcomers.
- **Style:** Teach with lessons, friendly language, and clear milestones. Begin with learning outcomes.
- **Flow:** Use logical stages and checkpoints. Include diagrams early if helpful.
- **Minimal theory:** Link out to deep explanations as needed, without derailing the guide.
#### Tips
- **Purpose:** Intermediate/advanced how-tos, troubleshooting, and best practices for competent users.
- **Style:** Outcome-focused, concise, no re-explaining basic concepts.
- **Content:** Stepwise instructions, troubleshooting (symptoms and solutions), annotated code/config examples, highlight measurable improvements.
- **Encourage safe experimentation** and include references to prerequisites when relevant.
#### Reference
- **Purpose:** Exhaustive, factual technical information – APIs, commands, options.
- **Style:** Neutral, concise, free of tutorial/narrative. Entries are self-contained.
- **Content:** Use tables for options/flags; include runnable examples (verified), mark versions of features. Cross-link to Guides/Tips for context.
### FAQ Section
- **Include FAQ at end:** Summarize common questions in an actual Q&A format. Keep answers brief and link to longer explanations where needed. Maintain and update as new questions become relevant.
### Code Examples
- **Provide complete, realistic examples:** Snippets must be runnable and include all necessary context.
- **Demonstrate common usage first:** Show typical/simplest cases before advanced ones.
- **Comment non-obvious code:** Briefly explain necessary choices or "magic values."
- **Show expected output:** Where useful, display what output or result to expect.
- **Stick to one concept per example:** Prefer multiple concise examples over monolithic scripts.
# Exit Criteria
Documentation is finished when it meets all of these:
- **Skimmable structure:** Clear, informative headings with logical flow.
- **Visual aids present:** All complicated processes/relationships are illustrated where appropriate.
- **Linked external references:** All third-party tools and standards cited are linked on first mention.
- **Clear concept introduction:** All new terms are defined or hyperlinked upon first appearance.
- **Runnable examples:** All code/command examples are complete, tested, and output as described.
- **Consistent, clear style:** Terminology, tone, and structure are uniform.
- **Functional and high-quality:** Content is correct, complete, and user-friendly—fulfilling both technical and experiential needs.

After producing the documentation, review for accuracy, consistency, and renderability, and validate that all diagrams and complex elements display as intended. When diagrams, code examples, or referenced features cannot be verified directly, flag their status in a brief validation note and specify next steps if corrections are needed.
