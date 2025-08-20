#!/usr/bin/env bash

# Test script to verify the agent installation logic

set -euo pipefail

# Color codes for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}Testing AI Rules agent installation logic...${NC}"
echo ""

# Test 1: Verify all Claude frontmatter files exist
echo -e "${YELLOW}Test 1: Checking Claude frontmatter files...${NC}"
for agent in code-commenter code-reviewer content-writer pr-creator repo-onboarder test-runner; do
  if [ -f ".claude/agents/${agent}.md" ]; then
    echo -e "${GREEN}✓${NC} Found .claude/agents/${agent}.md"
  else
    echo -e "${RED}✗${NC} Missing .claude/agents/${agent}.md"
    exit 1
  fi
done
echo ""

# Test 2: Verify all shared content files exist
echo -e "${YELLOW}Test 2: Checking shared content files...${NC}"
for agent in code-commenter code-reviewer content-writer pr-creator repo-onboarder test-runner; do
  if [ -f ".shared/agents/${agent}.md" ]; then
    echo -e "${GREEN}✓${NC} Found .shared/agents/${agent}.md"
  else
    echo -e "${RED}✗${NC} Missing .shared/agents/${agent}.md"
    exit 1
  fi
done
echo ""

# Test 3: Verify all OpenCode frontmatter files exist
echo -e "${YELLOW}Test 3: Checking OpenCode frontmatter files...${NC}"
for agent in code-commenter code-reviewer content-writer pr-creator repo-onboarder test-runner; do
  if [ -f ".opencode/agents/${agent}.md" ]; then
    echo -e "${GREEN}✓${NC} Found .opencode/agents/${agent}.md"
  else
    echo -e "${RED}✗${NC} Missing .opencode/agents/${agent}.md"
    exit 1
  fi
done
echo ""

# Test 4: Verify frontmatter files only contain frontmatter
echo -e "${YELLOW}Test 4: Verifying Claude frontmatter structure...${NC}"
for agent in code-commenter code-reviewer content-writer pr-creator repo-onboarder test-runner; do
  lines=$(wc -l < ".claude/agents/${agent}.md")
  if [ "$lines" -lt 20 ]; then
    echo -e "${GREEN}✓${NC} .claude/agents/${agent}.md contains only frontmatter ($lines lines)"
  else
    echo -e "${RED}✗${NC} .claude/agents/${agent}.md seems too large for just frontmatter ($lines lines)"
    exit 1
  fi
done
echo ""

# Test 5: Verify shared content files have actual content
echo -e "${YELLOW}Test 5: Verifying shared content exists...${NC}"
for agent in code-commenter code-reviewer content-writer pr-creator repo-onboarder test-runner; do
  lines=$(wc -l < ".shared/agents/${agent}.md")
  if [ "$lines" -gt 10 ]; then
    echo -e "${GREEN}✓${NC} .shared/agents/${agent}.md has content ($lines lines)"
  else
    echo -e "${RED}✗${NC} .shared/agents/${agent}.md seems too small ($lines lines)"
    exit 1
  fi
done
echo ""

# Test 6: Test combining logic
echo -e "${YELLOW}Test 6: Testing combination logic...${NC}"
temp_file="/tmp/test_agent_combination.md"
test_agent="code-reviewer"

# Combine frontmatter and content
cat ".claude/agents/${test_agent}.md" > "$temp_file"
echo "" >> "$temp_file"
cat ".shared/agents/${test_agent}.md" >> "$temp_file"

# Check if combination worked
frontmatter_lines=$(wc -l < ".claude/agents/${test_agent}.md")
content_lines=$(wc -l < ".shared/agents/${test_agent}.md")
combined_lines=$(wc -l < "$temp_file")
expected_lines=$((frontmatter_lines + content_lines + 1))

if [ "$combined_lines" -eq "$expected_lines" ]; then
  echo -e "${GREEN}✓${NC} Combination logic works correctly"
  echo "  Frontmatter: $frontmatter_lines lines"
  echo "  Content: $content_lines lines"
  echo "  Combined: $combined_lines lines (expected $expected_lines)"
else
  echo -e "${RED}✗${NC} Combination logic failed"
  echo "  Expected $expected_lines lines, got $combined_lines"
  exit 1
fi
echo ""

# Test 7: Verify OpenCode frontmatter has required fields
echo -e "${YELLOW}Test 7: Checking OpenCode frontmatter structure...${NC}"
for agent in code-commenter code-reviewer content-writer pr-creator repo-onboarder test-runner; do
  if grep -q "^description:" ".opencode/agents/${agent}.md" && \
     grep -q "^mode:" ".opencode/agents/${agent}.md" && \
     grep -q "^model:" ".opencode/agents/${agent}.md"; then
    echo -e "${GREEN}✓${NC} .opencode/agents/${agent}.md has required fields"
  else
    echo -e "${RED}✗${NC} .opencode/agents/${agent}.md missing required fields"
    exit 1
  fi
done
echo ""

echo -e "${GREEN}=== All tests passed! ===${NC}"
echo ""
echo -e "${CYAN}The agent structure is ready for installation.${NC}"
echo -e "${CYAN}Run ./install.sh to install the agents to:${NC}"
echo "  • Claude: ~/.claude/agents/"
echo "  • OpenCode: ~/.config/opencode/agent/"