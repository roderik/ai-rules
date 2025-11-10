#!/usr/bin/env bash
#
# validate_manifests.sh - Validate Kubernetes manifests before applying
#
# Usage: bash validate_manifests.sh <manifest-dir-or-file>
#
# Example: bash validate_manifests.sh ./k8s-manifests/
#

set -euo pipefail

TARGET="${1:-.}"
ERRORS=0

echo "🔍 Validating Kubernetes manifests: $TARGET"
echo ""

# Check if target exists
if [ ! -e "$TARGET" ]; then
  echo "❌ Error: $TARGET does not exist"
  exit 1
fi

# Function to print section header
print_header() {
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 1. kubectl dry-run validation
print_header "1. kubectl Client-Side Validation"
if command -v kubectl &> /dev/null; then
  echo "Running: kubectl apply --dry-run=client..."
  if kubectl apply -f "$TARGET" --dry-run=client > /dev/null 2>&1; then
    echo "✅ Client-side validation passed"
  else
    echo "❌ Client-side validation failed"
    kubectl apply -f "$TARGET" --dry-run=client 2>&1 | head -20
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "⚠️  kubectl not found, skipping"
fi
echo ""

# 2. kubectl server-side dry-run
print_header "2. kubectl Server-Side Validation"
if command -v kubectl &> /dev/null; then
  # Check if cluster is accessible
  if kubectl cluster-info &> /dev/null; then
    echo "Running: kubectl apply --dry-run=server..."
    if kubectl apply -f "$TARGET" --dry-run=server > /dev/null 2>&1; then
      echo "✅ Server-side validation passed"
    else
      echo "❌ Server-side validation failed"
      kubectl apply -f "$TARGET" --dry-run=server 2>&1 | head -20
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo "⚠️  No Kubernetes cluster accessible, skipping server-side validation"
  fi
else
  echo "⚠️  kubectl not found, skipping"
fi
echo ""

# 3. kubeval validation
print_header "3. kubeval Schema Validation"
if command -v kubeval &> /dev/null; then
  echo "Running: kubeval..."
  if kubeval "$TARGET" 2>&1 | tee /tmp/kubeval-output.txt; then
    if grep -q "invalid" /tmp/kubeval-output.txt; then
      echo "❌ kubeval found validation errors"
      ERRORS=$((ERRORS + 1))
    else
      echo "✅ kubeval validation passed"
    fi
  else
    echo "❌ kubeval validation failed"
    ERRORS=$((ERRORS + 1))
  fi
  rm -f /tmp/kubeval-output.txt
else
  echo "⚠️  kubeval not found, skipping"
  echo "   Install: brew install kubeval"
  echo "   Or: https://github.com/instrumenta/kubeval"
fi
echo ""

# 4. kube-linter security and best practices
print_header "4. kube-linter Security & Best Practices"
if command -v kube-linter &> /dev/null; then
  echo "Running: kube-linter lint..."
  if kube-linter lint "$TARGET" 2>&1 | tee /tmp/kube-linter-output.txt; then
    echo "✅ kube-linter checks passed"
  else
    if grep -q "Error:" /tmp/kube-linter-output.txt; then
      echo "❌ kube-linter found issues"
      ERRORS=$((ERRORS + 1))
    else
      echo "⚠️  kube-linter found warnings (not blocking)"
    fi
  fi
  rm -f /tmp/kube-linter-output.txt
else
  echo "⚠️  kube-linter not found, skipping"
  echo "   Install: brew install kube-linter"
  echo "   Or: https://github.com/stackrox/kube-linter"
fi
echo ""

# 5. YAML syntax validation
print_header "5. YAML Syntax Validation"
if command -v yamllint &> /dev/null; then
  echo "Running: yamllint..."
  if yamllint -d relaxed "$TARGET" 2>&1; then
    echo "✅ YAML syntax valid"
  else
    echo "❌ YAML syntax errors found"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "⚠️  yamllint not found, skipping"
  echo "   Install: pip install yamllint"
fi
echo ""

# 6. Security checks
print_header "6. Security Checks"
echo "Checking for common security issues..."

# Check for 'latest' image tags
if grep -r "image:.*:latest" "$TARGET" 2>/dev/null; then
  echo "⚠️  Warning: Found 'latest' image tags (use specific versions)"
  echo ""
fi

# Check for privileged containers
if grep -r "privileged: true" "$TARGET" 2>/dev/null; then
  echo "❌ Error: Found privileged containers (security risk)"
  ERRORS=$((ERRORS + 1))
  echo ""
fi

# Check for hostNetwork
if grep -r "hostNetwork: true" "$TARGET" 2>/dev/null; then
  echo "❌ Error: Found hostNetwork: true (security risk)"
  ERRORS=$((ERRORS + 1))
  echo ""
fi

# Check for missing resource limits
if grep -rL "limits:" "$TARGET" 2>/dev/null | grep -E '\.(yaml|yml)$'; then
  echo "⚠️  Warning: Some files missing resource limits"
  echo ""
fi

# Check for readOnlyRootFilesystem
if grep -rL "readOnlyRootFilesystem" "$TARGET" 2>/dev/null | grep -E '\.(yaml|yml)$' | grep -v "test\|config\|secret"; then
  echo "⚠️  Warning: Consider using readOnlyRootFilesystem: true"
  echo ""
fi

echo "Security checks completed"
echo ""

# 7. Best practices check
print_header "7. Best Practices Check"
echo "Checking for Kubernetes best practices..."

# Check for liveness and readiness probes
if grep -rL "livenessProbe\|readinessProbe" "$TARGET" 2>/dev/null | grep -E 'kind: (Deployment|StatefulSet)' | cut -d: -f1 | sort -u; then
  echo "⚠️  Warning: Some Deployments/StatefulSets missing health probes"
  echo ""
fi

# Check for pod anti-affinity
if grep -rL "podAntiAffinity" "$TARGET" 2>/dev/null | grep -E 'kind: (Deployment|StatefulSet)' | cut -d: -f1 | sort -u; then
  echo "⚠️  Info: Consider adding pod anti-affinity for HA"
  echo ""
fi

# Check for PodDisruptionBudget
if ! grep -rq "kind: PodDisruptionBudget" "$TARGET" 2>/dev/null; then
  echo "⚠️  Info: Consider adding PodDisruptionBudget for production workloads"
  echo ""
fi

echo "Best practices check completed"
echo ""

# Final summary
print_header "Validation Summary"
if [ $ERRORS -eq 0 ]; then
  echo "✅ All validations passed!"
  echo ""
  echo "Next steps:"
  echo "  1. Review any warnings above"
  echo "  2. Apply manifests: kubectl apply -f $TARGET"
  echo "  3. Monitor rollout: kubectl rollout status deployment/<name>"
  exit 0
else
  echo "❌ Validation failed with $ERRORS error(s)"
  echo ""
  echo "Please fix the errors above before applying manifests."
  exit 1
fi
