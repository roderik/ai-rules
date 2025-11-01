---
description: Craft or enhance documentation efficiently
agent: content-writer
---

Current branch:
!`git branch --show-current`

Find and investigate the pre-existing documentation in this repository. Markdown files that should be considered:

!`bash -c 'fd -t f "\.md$"'`

Write or update the documentation for:

- if provided, focus on these topics: $ARGUMENTS
- any changes in the code:
    - if we are running in the `main` branch, do a general scan and handle the top 3 content that can be improved
    - if we are running in another branch, update the docs, based on the type of docs, with whatever we need to mention or change for the changes vs main.

Guidelines:

- Ensure your content is in line with the already written sections (or adjust
  them where needed)
- Verify that you are not hallucinating features, verify with source code in this repo
- Be very precise in your wording, locations of files and code snippets,
  developers will use this and should be able to use the docs as is
- Add clear placeholders for where screenshots should be included, do this by
  creating and setting one placeholder image (put it in the repo) and describing
  the content in the image caption
- does it adhere to the writing style described in the AGENTS.md.
- based on the source code, are there any factual errors or hallucinated content?
- do these pages follow the optimal template from The Good Docs (use context7 mcp to get the docs, key gitlab_tgdp/templates)
- are there any content gaps or pages that are missing and can be beneficial for the target reader profile?
- is all content present targetting the right audience? If not, adjust the content to the right audience and move information you would be deleting to the right section.
- Did we liberally use mermaid charts to improve understanding and break up
  code, but did not go overboard with useless charts?