# Evaluation Scenarios for rr-skill-creator

## Scenario 1: Basic Usage - Create Simple Tool Integration Skill

**Input:** "Create a skill for generating PDF reports from markdown files using a Python script"

**Expected Behavior:**

- Automatically activate when "create a skill" is mentioned
- Guide through skill creation process
- Create skill directory structure
- Write SKILL.md with proper frontmatter:
  - name: clear and specific
  - description: explicit with triggers
- Include when to use section
- Add workflow for generating PDFs
- Create script in scripts/ directory
- Reference script from SKILL.md
- Include example usage
- Follow progressive disclosure principle

**Success Criteria:**

- [ ] Creates skill directory with proper name
- [ ] SKILL.md has valid YAML frontmatter
- [ ] name field is clear (e.g., "pdf-reports")
- [ ] description includes "Use when..." statement
- [ ] description includes file type triggers (.md, .pdf)
- [ ] description includes example phrases
- [ ] "When to Use This Skill" section present
- [ ] Workflow section with clear steps
- [ ] Python script created in scripts/
- [ ] Script referenced in SKILL.md
- [ ] Example usage provided
- [ ] Follows template structure from skill-creator

## Scenario 2: Complex Scenario - Create Domain-Specific Skill with References

**Input:** "Create a skill for working with our company's financial data. We have specific schemas for transactions, invoices, and reports. Include documentation for our internal APIs and common workflows for financial analysts."

**Expected Behavior:**

- Load skill and understand complex domain skill
- Create comprehensive skill structure:
  - SKILL.md with proper metadata
  - references/ directory for detailed docs
  - Split content appropriately
- Write SKILL.md with:
  - Clear trigger conditions
  - Overview of financial domain
  - High-level workflows
  - References to detailed docs
- Create reference files:
  - schemas.md for data structures
  - api-docs.md for API reference
  - workflows.md for analyst procedures
- Keep SKILL.md lean (progressive disclosure)
- Include grep patterns for large references
- Follow best practices from skill-creator

**Success Criteria:**

- [ ] Skill directory created with proper name
- [ ] SKILL.md has proper frontmatter
- [ ] description mentions financial data, schemas, APIs
- [ ] description includes trigger phrases
- [ ] SKILL.md remains concise (< 500 lines)
- [ ] references/ directory created
- [ ] schemas.md contains data structures
- [ ] api-docs.md contains API documentation
- [ ] workflows.md contains analyst procedures
- [ ] SKILL.md references documentation files
- [ ] Grep patterns included for searching references
- [ ] No duplication between SKILL.md and references
- [ ] Follows progressive disclosure principle

## Scenario 3: Error Handling - Skill Not Triggering

**Input:** "I created a skill for PowerPoint generation but Claude isn't using it when I ask to create slides."

**Expected Behavior:**

- Recognize skill activation issue
- Check SKILL.md frontmatter description
- Identify missing trigger phrases
- Explain how skill activation works
- Review description for:
  - "Use when..." statement
  - File type mentions (.pptx)
  - Example trigger phrases
- Provide improved description
- Explain trigger phrase importance
- Suggest testing with explicit phrases
- Reference skill-creator guidelines

**Success Criteria:**

- [ ] Reads the SKILL.md file
- [ ] Examines frontmatter description
- [ ] Identifies missing or weak triggers
- [ ] Explains skill activation mechanism
- [ ] Checks for "Use when..." statement
- [ ] Checks for file type mentions
- [ ] Checks for example phrases
- [ ] Provides improved description with:
  - Clear "Use when..." statement
  - .pptx file type mention
  - Example phrases: "Create slides", "Make a presentation"
- [ ] Explains why explicit triggers matter
- [ ] Suggests test phrases to verify activation
- [ ] References skill-creator description guidelines
