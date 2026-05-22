#!/usr/bin/env bats

# Role resource status
@test "role.iam.aws.m.upbound.io synced" {
  run bash -c "kubectl get roles.iam.aws.m.upbound.io integration-test-iam-role -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "role.iam.aws.m.upbound.io ready" {
  run bash -c "kubectl get roles.iam.aws.m.upbound.io integration-test-iam-role -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "podidentityassociation.eks.aws.m.upbound.io synced" {
  run bash -c "kubectl get podidentityassociation.eks.aws.m.upbound.io integration-test-eks-pod-identity -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "podidentityassociation.eks.aws.m.upbound.io ready" {
  run bash -c "kubectl get podidentityassociation.eks.aws.m.upbound.io integration-test-eks-pod-identity -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}
