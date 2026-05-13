#!/usr/bin/env bash
set -euo pipefail
source bash-functions.sh

cluster=$1
cluster_role=$2
argocd_namespace=$(jq -er .argocd_namespace environments/$cluster_role.json)
crossplane_chart_version=$(jq -er .crossplane_chart_version environments/$cluster_role.json)

# confirm new version has been synced
validate_argocore_helm_app_resource "$argocd_namespace" "crossplane" "$crossplane_chart_version"

# run basic smoketest for crossplane operator health
bats test/crossplane-service-check.bats

# write a value, then read it - proves functional health

# Files that will be applied
TEST_FILES=("test/test-secret.yaml" "test/write-test-secret.yaml" "test/read-test-secret.yaml")
cleanup() {
  echo "Deleting test files..."
  for f in "${TEST_FILES[@]}"; do
    kubectl delete -f "$f" --ignore-not-found=true
    echo "  removed: $f"
  done
}
trap cleanup EXIT INT TERM


# expect value in 1password vault to match what was just written
if [[ "$ACTUAL" == "$uuid" ]]; then
  echo "✓ PASS: test-uuid-value matches expected value"
  EXIT_CODE=0
else
  echo "✗ FAIL: test-uuid-value does not match"
  echo "  expected: $uuid"
  echo "  actual:   $ACTUAL"
  EXIT_CODE=1
fi
exit $EXIT_CODE