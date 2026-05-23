#!/usr/bin/env bats

# Role resource status
@test "PodIdentityAssociation.platform.psk.io synced" {
  run bash -c "kubectl get PodIdentityAssociation.platform.psk.io test-pod-identity-xrd -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "PodIdentityAssociation.platform.psk.io ready" {
  run bash -c "kubectl get PodIdentityAssociation.platform.psk.io test-pod-identity-xrd -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}
