#!/usr/bin/env bash

# Validate all skills in .claude/skills directory
# Usage: ./.github/validate-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/../.claude/skills"
VALIDATOR="$SKILLS_DIR/rr-skill-creator/scripts/quick_validate.py"

if [ ! -f "$VALIDATOR" ]; then
  echo "❌ Validator script not found: $VALIDATOR"
  exit 1
fi

echo "🔍 Validating all skills..."
echo ""

FAILED=0
PASSED=0
TOTAL=0

for skill_dir in "$SKILLS_DIR"/*/; do
  if [ -f "${skill_dir}SKILL.md" ]; then
    skill_name=$(basename "$skill_dir")
    TOTAL=$((TOTAL + 1))

    echo "Validating: $skill_name"

    if python3 "$VALIDATOR" "$skill_dir"; then
      echo "✅ $skill_name is valid"
      PASSED=$((PASSED + 1))
    else
      echo "❌ $skill_name validation failed"
      FAILED=$((FAILED + 1))
    fi

    echo ""
  fi
done

echo "=========================================="
echo "📊 Validation Summary"
echo "=========================================="
echo "Total skills: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo "✅ All skills are valid!"
  exit 0
else
  echo "❌ Some skills failed validation"
  exit 1
fi
