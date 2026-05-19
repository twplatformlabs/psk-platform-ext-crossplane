#!/usr/bin/env bash
set -euo pipefail
source bash-functions.sh

cluster=$1
argocd_namespace=$(jq -er .argocd_namespace environments/$cluster.json)
crossplane_chart_version=$(jq -er .crossplane_chart_version environments/$cluster.json)
aws_account_id=$(jq -er .aws_account_id "$cluster".auto.tfvars.json)
aws_assume_role=$(jq -er .aws_assume_role "$cluster".auto.tfvars.json)
export AWS_DEFAULT_REGION=$(jq -er .aws_region "$cluster".auto.tfvars.json)

# confirm new version has been synced
validate_argocore_helm_app_resource "$argocd_namespace" "crossplane" "$crossplane_chart_version"

# run basic smoketest for crossplane operator and provider health
bats test/crossplane-service-check.bats


# Files that will be applied
TEST_FILES=("test/fixture-configmap.yaml" "test/fixture-xrd.yaml" "test/fixture-composition.yaml" "test/fixture-claim.yaml")
cleanup() {
  echo "Deleting test files..."
  for f in "${TEST_FILES[@]}"; do
    kubectl delete -f "$f" --ignore-not-found=true
    echo "  removed: $f"
  done
}
trap cleanup EXIT INT TERM

# use test fixxtures to establish basic provider and function health
# Apply the ConfigMap first so function-extra-resources has something to fetch
kubectl apply -f test/fixture-configmap.yaml

# Install the XRD and Composition
kubectl apply -f test/fixture-xrd.yaml
kubectl apply -f test/fixture-composition.yaml

# Wait a few seconds for the XRD to be established
kubectl wait --for=condition=Established xrd/xcrossplanetests.test.example.org

# Fire the claim and wait 3 minutes
kubectl apply -f test/fixture-claim.yaml
sleep 180

bats test/crossplane-fixture-validation.bats

awsAssumeRole "${aws_account_id}" "${aws_assume_role}"

if ROLE_ARN=$(aws iam get-role --role-name crossplane-smoke-test-templated \
  --query 'Role.Arn' --output text 2>/dev/null); then
  echo "✓ PASS: test fixture role found with ARN: $ROLE_ARN"
else
  echo "✗ FAIL: Role 'crossplane-smoke-test-templated' not found in AWS"
  exit 1
fi
