#!/usr/bin/env bats

# operator
@test "crossplane status is Running" {
  run bash -c "kubectl get pods --selector app=crossplane -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}

@test "crossplane-rbac-manager status is Running" {
  run bash -c "kubectl get pods --selector app=crossplane-rbac-manager -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}


# ========================================================== functions
@test "extra-resources status is Running" {
  run bash -c "kubectl get pods --selector pkg.crossplane.io/function=crossplane-contrib-function-extra-resources -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}

@test "go-templating status is Running" {
  run bash -c "kubectl get pods --selector pkg.crossplane.io/function=crossplane-contrib-function-go-templating -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}

@test "patch-and-transform status is Running" {
  run bash -c "kubectl get pods --selector pkg.crossplane.io/function=crossplane-contrib-function-patch-and-transform -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}


# ========================================================== providers
@test "family-aws status is Running" {
  run bash -c "kubectl get pods --selector pkg.crossplane.io/provider=upbound-provider-family-aws -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}

@test "aws-iam status is Running" {
  run bash -c "kubectl get pods --selector pkg.crossplane.io/provider=upbound-provider-aws-iam -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}

@test "aws-eks status is Running" {
  run bash -c "kubectl get pods --selector pkg.crossplane.io/provider=upbound-provider-aws-eks -n crossplane-system"
  [[ "${output}" =~ "Running" ]]
}
