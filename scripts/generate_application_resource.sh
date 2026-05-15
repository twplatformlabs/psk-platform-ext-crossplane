#!/usr/bin/env bash
source bash-functions.sh

cluster_role=$1

crossplane_chart_version=$(jq -er .crossplane_chart_version environments/$cluster_role.json)
argocd_namespace=$(jq -er .argocd_namespace environments/$cluster_role.json)

echo "Application resource and configuration files for crossplane"
echo "crossplane chart version: $crossplane_chart_version"
echo "creating deploy-files directory for all the files that will written to psk-platform-control-plane-configuration repository"
mkdir deploy-files
mkdir deploy-files/crossplane
mkdir deploy-files/crossplane-aws

# generate application.yaml for both Applications then stage the files for writing to the app-of-app config repo
echo "generating application.yaml"
cat <<EOF > deploy-files/crossplane/application.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: crossplane
  namespace: $argocd_namespace
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  project: psk-aws-control-plane-configuration

  sources:
    - repoURL: https://charts.crossplane.io/stable
      chart: crossplane
      targetRevision: $crossplane_chart_version
      helm:
        valueFiles:
          - \$config/roles/$cluster_role/crossplane/default-values.yaml
          - \$config/roles/$cluster_role/crossplane/$cluster_role-values.yaml
    - repoURL: https://github.com/twplatformlabs/psk-aws-control-plane-configuration
      targetRevision: HEAD
      ref: config
  destination:
    server: https://kubernetes.default.svc
    namespace: crossplane-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - ServerSideApply=true
      - CreateNamespace=true
    managedNamespaceMetadata:
      labels:
        app.kubernetes.io/managed-by: psk-platform-ext-crossplane
        platform-vault: "true"
    retry:
      limit: 5
      backoff:
        duration: 30s
        factor: 2
        maxDuration: 5m
EOF
cat deploy-files/crossplane/application.yaml

cat <<EOF > deploy-files/crossplane-aws/application.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: crossplane-aws
  namespace: $argocd_namespace
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: psk-aws-control-plane-configuration

  source:
    - repoURL: https://github.com/twplatformlabs/psk-platform-ext-crossplane/chart
      chart: crossplane-aws
      targetRevision: HEAD
      helm:
        valueFiles:
          - \$config/roles/$cluster_role/crossplane-aws/aws-default-values.yaml
    - repoURL: https://github.com/twplatformlabs/psk-aws-control-plane-configuration
      targetRevision: HEAD
      ref: config
  destination:
    server: https://kubernetes.default.svc
    namespace: crossplane-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - ServerSideApply=true
    retry:
      limit: 5
      backoff:
        duration: 30s
        factor: 2
        maxDuration: 5m
EOF
cat deploy-files/crossplane-aws/application.yaml

echo "copying default values"
cp -v deploy-templates/default-values.yaml deploy-files/crossplane/default-values.yaml
cp -v deploy-templates/$cluster_role-values.yaml deploy-files/crossplane/$cluster_role-values.yaml
cp -v deploy-templates/aws-default-values.yaml deploy-files/crossplane-aws/aws-default-values.yaml
