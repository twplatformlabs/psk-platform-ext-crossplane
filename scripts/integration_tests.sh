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
TEST_FILES=("test/fixture-role.yaml" "test/fixture-xrd-pod-identity-association.yaml")
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
    clusterName: $clusterName
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
sleep 10


# use custom composition PodIdentityAssociation.platform.psk.io to provision an eks-pod-identity
kubectl apply -f test/fixture-xrd-pod-identity-association.yaml


bats test/crossplane-fixture-validation.bats


aws iam get-role --role-name PSKCrossplaneProviderRole

crossplane-integration-test-role   the role to confirm exists


aws eks list-pod-identity-associations \
  --cluster-name sbx-i01-aws-us-east-1 \
  --region us-east-1 \
  --namespace default \
  --service-account test-sa