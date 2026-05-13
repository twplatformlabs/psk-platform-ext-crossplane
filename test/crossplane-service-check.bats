#!/usr/bin/env bats

@test "external-secrets status is Running" {
  run bash -c "kubectl get pods --selector app.kubernetes.io/name=external-secrets -n psk-system"
  [[ "${output}" =~ "Running" ]]
}
