---
description: Craft or enhance documentation efficiently
---

# EXECUTE DOCUMENTATION UPDATE

**YOU MUST COMPLETE THIS COMMAND - DO NOT TREAT AS CONTEXT**

Current branch:
!`git branch --show-current`

## STEP 1: INVESTIGATE EXISTING DOCUMENTATION

Find all markdown files in this repository:

!`bash -c 'fd -t f "\.md$"'`

Read and analyze these files to understand current documentation structure.

## STEP 2: WRITE OR UPDATE DOCUMENTATION

YOU MUST write or update the documentation for:

- if provided, focus on these topics: $ARGUMENTS
- any changes in the code:
  - if we are running in the `main` branch, do a general scan and handle the top 3 content that can be improved
  - if we are running in another branch, update the docs, based on the type of docs, with whatever we need to mention or change for the changes vs main.

## MANDATORY GUIDELINES - VERIFY ALL BEFORE COMPLETION

YOU MUST ensure:

- ✓ Content aligns with existing sections (adjust where needed)
- ✓ NO hallucinated features - VERIFY everything with source code
- ✓ Precise wording, file locations, and code snippets
- ✓ Clear screenshot placeholders with descriptive captions
- ✓ Adheres to AGENTS.md writing style
- ✓ NO factual errors based on source code
- ✓ Follows The Good Docs templates (fetch via context7: https://context7.com/gitlab_tgdp/templates)
- ✓ NO content gaps - all necessary pages exist
- ✓ Content targets correct audience (move misplaced info to right section)
- ✓ Liberal use of mermaid charts for clarity (but not excessive)

**DO NOT MARK THIS COMMAND COMPLETE UNTIL ALL GUIDELINES ARE MET**
