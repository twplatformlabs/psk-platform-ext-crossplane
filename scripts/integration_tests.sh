#!/usr/bin/env bash
set -euo pipefail
source bash-functions.sh

cluster=$1
argocd_namespace=$(jq -er .argocd_namespace environments/$cluster.json)
crossplane_chart_version=$(jq -er .crossplane_chart_version environments/$cluster.json)
aws_account_id=$(jq -er .aws_account_id environments/"$cluster".json)
aws_assume_role=$(jq -er .aws_assume_role environments/"$cluster".json)
export AWS_DEFAULT_REGION=$(jq -er .aws_region environments/"$cluster".json)

# confirm new version has been synced
validate_argocore_helm_app_resource "$argocd_namespace" "crossplane" "$crossplane_chart_version"

# run basic smoketest for crossplane operator and provider health
bats test/crossplane-service-check.bats

# Files that will be applied
TEST_FILES=("test/crossplane-provider-validation/fixture-iam-provider.yaml" \
            "test/crossplane-provider-validation/fixture-eks-provider.yaml" \
            "test/crossplane-platform-feastures-validation/fixture-xrd-pod-identity-association.yaml")

cleanup() {
  echo "Deleting test files..."
  for f in "${TEST_FILES[@]}"; do
    kubectl delete -f "$f" --ignore-not-found=true
    echo "  removed: $f"
  done
}
trap cleanup EXIT INT TERM

# Validate basic provider functionality
kubectl apply -f test/crossplane-provider-validation/fixture-iam-provider.yaml
cat <<EOF > test/crossplane-provider-validation/fixture-eks-provider.yaml
apiVersion: eks.aws.m.upbound.io/v1beta1
kind: PodIdentityAssociation
metadata:
  name: integration-test-eks-pod-identity
spec:
  forProvider:
    region: us-east-1
    clusterName: $cluster
    namespace: default
    serviceAccount: integration-test-eks-pod-identity-sa
    roleArnRef:
      name: integration-test-iam-role
      namespace: default
  providerConfigRef:
    kind: ClusterProviderConfig
    name: podidentity
EOF
kubectl apply -f test/crossplane-provider-validation/fixture-eks-provider.yaml

# validate platform feature compositions
# eks-pod-identities
kubectl apply -f test/fixture-xrd-pod-identity-association.yaml
sleep 10

# run k8s resource validation
bats test/crossplane-provider-validation/k8s-resource-validation.bats
bats test/crossplane-platform-features-validation/k8s-resource-validation.bats

# run aws api-check validation
awsAssumeRole "${aws_account_id}" "${aws_assume_role}"

CLUSTER_NAME=$cluster bats test/crossplane-provider-validation/aws-validation.bats
CLUSTER_NAME=$cluster bats test/crossplane-platform-features-validation/aws-validation.bats
