#!/usr/bin/env bats

# operator
@test "fixture is synced and ready" {
  run bash -c "kubectl get crossplanetest smoke-test-1 -n default -w "
  [[ "${output}" =~ "SYNCED=True" ]]
  [[ "${output}" =~ "READY=True" ]]
}

@test "crossplane-rbac-manager status is Running" {
  run bash -c "kubectl get pods --selector app=crossplane-rbac-manager -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}


on test/role.yaml to confirm 'create' role works
k get roles.iam.aws.upbound.io crossplane-integration-test-role -o jsonpath='{.status.conditions[?(@.type=="Synced")].status}'
 then also @.type=="Ready")].status}'

