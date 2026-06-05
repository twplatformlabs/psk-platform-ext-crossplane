#!/usr/bin/env bash
set -euo pipefail
source bash-functions.sh

cluster=$1
cluster_role=$2
argocd_namespace=$(jq -er .argocd_namespace environments/$cluster_role.json)
crossplane_chart_version=$(jq -er .crossplane_chart_version environments/$cluster_role.json)
region=$(jq -er .aws_region environments/$cluster_role.json)

# confirm new version has been synced
# rolling update requires some time
sleep 240
validate_argocore_helm_app_resource "$argocd_namespace" "crossplane" "$crossplane_chart_version"

# run basic smoketest for crossplane operator and provider health
bats test/crossplane-service-check.bats

# Files that will be applied
TEST_FILES=("test/crossplane-provider-validation/fixture-iam-provider.yaml" \
            "test/crossplane-provider-validation/fixture-eks-provider.yaml" \
            "test/crossplane-platform-features-validation/fixture-xrd-pod-identity-association.yaml" \
            "test/crossplane-platform-features-validation/fixture-xrd-s3bucket.yaml")

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
  namespace: default
spec:
  forProvider:
    region: $region
    clusterName: $cluster
    namespace: default
    serviceAccount: integration-test-eks-pod-identity-sa
    roleArnRef:
      name: integration-test-iam-role
      namespace: default
  providerConfigRef:
    kind: ClusterProviderConfig
    name: aws
EOF
cat test/crossplane-provider-validation/fixture-eks-provider.yaml
kubectl apply -f test/crossplane-provider-validation/fixture-eks-provider.yaml

# deploy platform feature composition tests
kubectl apply -f test/crossplane-platform-features-validation/fixture-xrd-pod-identity-association.yaml
kubectl apply -f test/crossplane-platform-features-validation/fixture-xrd-s3bucket.yaml
sleep 240

# run k8s resource validation
bats test/crossplane-provider-validation/resource-validation.bats
bats test/crossplane-platform-features-validation/resource-validation.bats
