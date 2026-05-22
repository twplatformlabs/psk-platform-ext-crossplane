#!/usr/bin/env bats

setup() {
  if [[ -z "${CLUSTER_NAME}" ]]; then
    echo "ERROR: CLUSTER_NAME environment variable is not set"
    echo "Example:"
    echo "  CLUSTER_NAME=my-cluster bats tests.bats"
    exit 1
  fi
}

# EKS Pod Identity Association
@test "EKS Pod Identity Association created" {
  run bash -c "aws eks list-pod-identity-associations --cluster-name ${CLUSTER_NAME} --region us-east-1 --namespace default --service-account test-sa"
  [[ "${output}" =~ "test-sa" ]]
}
