#!/usr/bin/env bats

setup() {
  if [[ -z "${CLUSTER_NAME}" ]]; then
    echo "ERROR: CLUSTER_NAME environment variable is not set"
    echo "Example:"
    echo "  CLUSTER_NAME=my-cluster bats tests.bats"
    exit 1
  fi
}

# IAM Role 
@test "AWS IAM Role created" {
  run bash -c "aws iam get-role --role-name integration-test-iam-role"
  [[ "${output}" =~ "Crossplane AWS IAM provider is working" ]]
}

# EKS Pod Identity Association
@test "EKS Pod Identity Association created" {
  run bash -c "aws eks list-pod-identity-associations --cluster-name ${CLUSTER_NAME} --region us-east-1 --namespace default --service-account integration-test-eks-pod-identity-sa"
  [[ "${output}" =~ "integration-test-eks-pod-identity-sa" ]]
}
