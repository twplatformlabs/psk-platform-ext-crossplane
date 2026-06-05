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
  run bash -c "kubectl get roles.iam.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "roles.iam.aws.m.upbound.io synced" {
  run bash -c "kubectl get roles.iam.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "policies.iam.aws.m.upbound.io ready" {
  run bash -c "kubectl get policies.iam.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "policies.iam.aws.m.upbound.io synced" {
  run bash -c "kubectl get policies.iam.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "RolePolicyAttachment.iam.aws.m.upbound.io ready" {
  run bash -c "kubectl get RolePolicyAttachment.iam.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "RolePolicyAttachment.iam.aws.m.upbound.io synced" {
  run bash -c "kubectl get RolePolicyAttachment.iam.aws.m.upbound.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "PodIdentityAssociation.platform.psk.io for test-bucket ready" {
  run bash -c "kubectl get PodIdentityAssociation.platform.psk.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "PodIdentityAssociation.platform.psk.io for test-bucket synced" {
  run bash -c "kubectl get PodIdentityAssociation.platform.psk.io test-bucket -n default -o jsonpath='{.status.conditions[?(@.type==\"Synced\")].status}'"
  [[ "${output}" =~ "True" ]]
}

@test "aws pod-identity-association" {
  run bash -c "aws eks list-pod-identity-associations --cluster-name ${CLUSTER_NAME} --namespace default --region ${AWS_REGION}"
  [[ "${output}" =~ "\"associationId\": \"a-" ]]
  #[[ "${output}" =~ "associationId" ]]
}

@test "aws bucket-lifecycle-configuration data expiration" {
  run bash -c "aws s3api get-bucket-lifecycle-configuration --bucket test-bucket --region ${AWS_REGION}"
  #[[ "${output}" =~ "\"associationId\": \"a-" ]]
  [[ "${output}" =~ "associationId" ]]
}

# aws s3api get-bucket-lifecycle-configuration --bucket "$BUCKET"
# {
#     "TransitionDefaultMinimumObjectSize": "all_storage_classes_128K",
#     "Rules": [
#         {
#             "Expiration": {
#                 "Days": 3
#             },
#             "ID": "expire",
#             "Filter": {},
#             "Status": "Enabled"
#         }
#     ]
# }

# aws s3api get-bucket-encryption --bucket "$BUCKET"
# {
#     "ServerSideEncryptionConfiguration": {
#         "Rules": [
#             {
#                 "ApplyServerSideEncryptionByDefault": {
#                     "SSEAlgorithm": "AES256"
#                 },
#                 "BucketKeyEnabled": false
#             }
#         ]
#     }
# }

# aws s3api get-public-access-block --bucket "$BUCKET"
# {
#     "PublicAccessBlockConfiguration": {
#         "BlockPublicAcls": true,
#         "IgnorePublicAcls": true,
#         "BlockPublicPolicy": true,
#         "RestrictPublicBuckets": true
#     }
# }

# k get podidentityassociations -n default -o yaml
# apiVersion: v1
# items:
# - apiVersion: eks.aws.m.upbound.io/v1beta1
#   kind: PodIdentityAssociation
#   metadata:
#     annotations:
#       crossplane.io/composition-resource-name: pod-identity-association
#       crossplane.io/external-create-pending: "2026-06-04T23:20:20Z"
#       crossplane.io/external-create-succeeded: "2026-06-04T23:20:20Z"
#       crossplane.io/external-name: a-oxq8hvs7csrse9dqe
#     creationTimestamp: "2026-06-04T23:20:18Z"
#     finalizers:
#     - finalizer.managedresource.crossplane.io
#     generation: 3
#     labels:
#       crossplane.io/composite: test-bucket
#     name: test-bucket
#     namespace: default
#     ownerReferences:
#     - apiVersion: platform.psk.io/v1alpha1
#       blockOwnerDeletion: true
#       controller: true
#       kind: PodIdentityAssociation
#       name: test-bucket
#       uid: 26107441-81f1-4d59-a2a0-f26b7ba6d2ec
#     resourceVersion: "304961788"
#     uid: 92fe140c-4894-4eb2-b744-b20ba3e4dd0f
#   spec:
#     forProvider:
#       clusterName: sbx-i01-aws-us-east-1
#       namespace: default
#       region: us-east-1
#       roleArn: arn:aws:iam::090950721693:role/test-bucket
#       roleArnRef:
#         name: test-bucket
#         namespace: default
#       serviceAccount: s3bucket-test
#       tags:
#         crossplane-kind: podidentityassociation.eks.aws.m.upbound.io
#         crossplane-name: test-bucket
#         crossplane-providerconfig: aws
#     initProvider: {}
#     managementPolicies:
#     - '*'
#     providerConfigRef:
#       kind: ClusterProviderConfig
#       name: aws
#   status:
#     atProvider:
#       associationArn: arn:aws:eks:us-east-1:090950721693:podidentityassociation/sbx-i01-aws-us-east-1/a-oxq8hvs7csrse9dqe
#       associationId: a-oxq8hvs7csrse9dqe
#       clusterName: sbx-i01-aws-us-east-1
#       disableSessionTags: false
#       id: a-oxq8hvs7csrse9dqe
#       namespace: default
#       region: us-east-1
#       roleArn: arn:aws:iam::090950721693:role/test-bucket
#       serviceAccount: s3bucket-test
#       tags:
#         crossplane-kind: podidentityassociation.eks.aws.m.upbound.io
#         crossplane-name: test-bucket
#         crossplane-providerconfig: aws
#       tagsAll:
#         crossplane-kind: podidentityassociation.eks.aws.m.upbound.io
#         crossplane-name: test-bucket
#         crossplane-providerconfig: aws
#     conditions:
#     - lastTransitionTime: "2026-06-04T23:20:20Z"
#       observedGeneration: 3
#       reason: ReconcileSuccess
#       status: "True"
#       type: Synced
#     - lastTransitionTime: "2026-06-04T23:20:21Z"
#       reason: Available
#       status: "True"
#       type: Ready
#     - lastTransitionTime: "2026-06-04T23:20:20Z"
#       reason: Success
#       status: "True"
#       type: LastAsyncOperation
# kind: List
# metadata:
#   resourceVersion: ""


# k get buckets -o yaml
# apiVersion: v1
# items:
# - apiVersion: s3.aws.m.upbound.io/v1beta1
#   kind: Bucket
#   metadata:
#     annotations:
#       crossplane.io/composition-resource-name: bucket
#       crossplane.io/external-create-pending: "2026-06-04T23:33:59Z"
#       crossplane.io/external-create-succeeded: "2026-06-04T23:33:59Z"
#       crossplane.io/external-name: sbx-default-s3bucket-test-1c3f87eb
#     creationTimestamp: "2026-06-04T23:20:17Z"
#     finalizers:
#     - finalizer.managedresource.crossplane.io
#     generation: 2
#     labels:
#       crossplane.io/composite: test-bucket
#     name: test-bucket
#     namespace: default
#     ownerReferences:
#     - apiVersion: platform.psk.io/v1alpha1
#       blockOwnerDeletion: true
#       controller: true
#       kind: S3Bucket
#       name: test-bucket
#       uid: e4ddb934-eacb-46f0-9188-075203a7255f
#     resourceVersion: "304966813"
#     uid: 74aa51b3-0a0a-4e5d-bfb4-a5dae964d149
#   spec:
#     forProvider:
#       region: us-east-1
#       tags:
#         crossplane-kind: bucket.s3.aws.m.upbound.io
#         crossplane-name: test-bucket
#         crossplane-providerconfig: aws
#     initProvider: {}
#     managementPolicies:
#     - '*'
#     providerConfigRef:
#       kind: ClusterProviderConfig
#       name: aws
#   status:
#     atProvider:
#       accelerationStatus: ""
#       arn: arn:aws:s3:::sbx-default-s3bucket-test-1c3f87eb
#       bucketDomainName: sbx-default-s3bucket-test-1c3f87eb.s3.amazonaws.com
#       bucketRegion: us-east-1
#       bucketRegionalDomainName: sbx-default-s3bucket-test-1c3f87eb.s3.us-east-1.amazonaws.com
#       forceDestroy: false
#       grant:
#       - id: 0500e82c15315564247509d34c489004aa15de191982a6019a1cb4754dfc1689
#         permissions:
#         - FULL_CONTROL
#         type: CanonicalUser
#         uri: ""
#       hostedZoneId: Z3AQBSTGFYJSTF
#       id: sbx-default-s3bucket-test-1c3f87eb
#       lifecycleRule:
#       - abortIncompleteMultipartUploadDays: 0
#         enabled: true
#         expiration:
#           date: ""
#           days: 3
#           expiredObjectDeleteMarker: false
#         id: expire
#         noncurrentVersionExpiration: {}
#         prefix: ""
#       logging: {}
#       objectLockConfiguration: {}
#       objectLockEnabled: false
#       policy: ""
#       region: us-east-1
#       replicationConfiguration: {}
#       requestPayer: BucketOwner
#       serverSideEncryptionConfiguration:
#         rule:
#           applyServerSideEncryptionByDefault:
#             kmsMasterKeyId: ""
#             sseAlgorithm: AES256
#           bucketKeyEnabled: false
#       tags:
#         crossplane-kind: bucket.s3.aws.m.upbound.io
#         crossplane-name: test-bucket
#         crossplane-providerconfig: aws
#       tagsAll:
#         crossplane-kind: bucket.s3.aws.m.upbound.io
#         crossplane-name: test-bucket
#         crossplane-providerconfig: aws
#       versioning:
#         enabled: false
#         mfaDelete: false
#       website: {}
#     conditions:
#     - lastTransitionTime: "2026-06-04T23:33:59Z"
#       observedGeneration: 2
#       reason: ReconcileSuccess
#       status: "True"
#       type: Synced
#     - lastTransitionTime: "2026-06-04T23:34:01Z"
#       reason: Available
#       status: "True"
#       type: Ready
#     - lastTransitionTime: "2026-06-04T23:34:00Z"
#       reason: Success
#       status: "True"
#       type: LastAsyncOperation
# kind: List
# metadata:
#   resourceVersion: ""