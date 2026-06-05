#!/usr/bin/env bats

setup() {
  if [[ -z "${CLUSTER_NAME}" ]]; then
    echo "ERROR: CLUSTER_NAME environment variable is not set"
    echo "Example:"
    echo "  CLUSTER_NAME=sbx-i01-aws-us-east-1 bats tests.bats"
    exit 1
  fi
  if [[ -z "${AWS_REGION}" ]]; then
    echo "ERROR: AWS_REGION environment variable is not set"
    echo "Example:"
    echo "  AWS_REGION=us-east-1 bats tests.bats"
    exit 1
  fi
  export BUCKET="$(kubectl get s3bucket "$XR_NAME" -n "$NAMESPACE" -o jsonpath='{.status.bucketName}')"
}


# PodIdentityAssociation.platform.psk.io resource status
@test "PodIdentityAssociation.platform.psk.io synced" {
  run bash -c "kubectl get PodIdentityAssociation.platform.psk.io test-pod-identity-xrd -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "PodIdentityAssociation.platform.psk.io ready" {
  run bash -c "kubectl get PodIdentityAssociation.platform.psk.io test-pod-identity-xrd -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

# s3bucket.platform.psk.io resource status
@test "buckets.s3.aws.m.upbound.io ready" {
  run bash -c "kubectl get buckets.s3.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "buckets.s3.aws.m.upbound.io synced" {
  run bash -c "kubectl get buckets.s3.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "BucketPublicAccessBlocks.s3.aws.m.upbound.io ready" {
  run bash -c "kubectl get BucketPublicAccessBlocks.s3.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "BucketPublicAccessBlocks.s3.aws.m.upbound.io synced" {
  run bash -c "kubectl get BucketPublicAccessBlocks.s3.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "BucketServerSideEncryptionConfiguration.s3.aws.m.upbound.io ready" {
  run bash -c "kubectl get BucketServerSideEncryptionConfiguration.s3.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "BucketServerSideEncryptionConfiguration.s3.aws.m.upbound.io synced" {
  run bash -c "kubectl get BucketServerSideEncryptionConfiguration.s3.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "BucketLifecycleConfiguration.s3.aws.m.upbound.io ready" {
  run bash -c "kubectl get BucketLifecycleConfiguration.s3.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "BucketLifecycleConfiguration.s3.aws.m.upbound.io synced" {
  run bash -c "kubectl get BucketLifecycleConfiguration.s3.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "roles.iam.aws.m.upbound.io ready" {
  run bash -c "kubectl get roles.iam.aws.m.upbound.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{range .items[0].status.conditions[?(@.type==\"Ready\")]}{.status}{end}'"
  [[ "${output}" =~ "True" ]]
}

@test "roles.iam.aws.m.upbound.io synced" {
  run bash -c "kubectl get roles.iam.aws.m.upbound.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{range .items[0].status.conditions[?(@.type==\"Synced\")]}{.status}{end}'"
  [[ "${output}" =~ "True" ]]
}

@test "policies.iam.aws.m.upbound.io ready" {
  run bash -c "kubectl get policies.iam.aws.m.upbound.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{range .items[0].status.conditions[?(@.type==\"Ready\")]}{.status}{end}'"
  [[ "${output}" =~ "True" ]]
}

@test "policies.iam.aws.m.upbound.io synced" {
  run bash -c "kubectl get policies.iam.aws.m.upbound.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{range .items[0].status.conditions[?(@.type==\"Synced\")]}{.status}{end}'"
  [[ "${output}" =~ "True" ]]
}

@test "RolePolicyAttachment.iam.aws.m.upbound.io ready" {
  run bash -c "kubectl get RolePolicyAttachment.iam.aws.m.upbound.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{range .items[0].status.conditions[?(@.type==\"Ready\")]}{.status}{end}'"
  [[ "${output}" =~ "True" ]]
}

@test "RolePolicyAttachment.iam.aws.m.upbound.io synced" {
  run bash -c "kubectl get RolePolicyAttachment.iam.aws.m.upbound.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{range .items[0].status.conditions[?(@.type==\"Synced\")]}{.status}{end}'"
  [[ "${output}" =~ "True" ]]
}

@test "PodIdentityAssociation.platform.psk.io for test-bucket ready" {
  run bash -c "kubectl get PodIdentityAssociation.platform.psk.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{range .items[0].status.conditions[?(@.type==\"Ready\")]}{.status}{end}'"
  [[ "${output}" =~ "True" ]]
}

@test "PodIdentityAssociation.platform.psk.io for test-bucket synced" {
  run bash -c "kubectl get PodIdentityAssociation.platform.psk.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{range .items[0].status.conditions[?(@.type==\"Synced\")]}{.status}{end}'"
  [[ "${output}" =~ "True" ]]
}

@test "PodIdentityAssociation for test-bucket exists in aws" {
  run bash -c "kubectl get PodIdentityAssociation.eks.aws.m.upbound.io -l crossplane.io/composite=test-bucket -n default -o jsonpath='{.items[0].status.atProvider.associationId}'"
  [[ "${output}" =~ "a-" ]]
}

@test "PodIdentityAssociation for test-bucket is paired to the correct sa" {
  run bash -c "kubectl get PodIdentityAssociation.eks.aws.m.upbound.io -l crossplane.io/composite=test-bucket -n default -o yaml"
  [[ "${output}" =~ "serviceAccount: s3bucket-test" ]]
}
