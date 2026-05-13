#!/usr/bin/env bash

cluster_role=$1

crossplane_chart_version=$(jq -er .crossplane_chart_version environments/$cluster_role.json)
argocd_namespace=$(jq -er .argocd_namespace environments/$cluster_role.json)

mkdir deploy-files

# update the application.yaml with the new chart version then stage the files for writing to the app-of-app config repo
cat <<EOF > deploy-files/application.yaml
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

---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: crossplane-providerconfig
  namespace: $argocd_namespace
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: psk-aws-control-plane-configuration

  source:
    repoURL: https://github.com/twplatformlabs/psk-aws-control-plane-configuration
    targetRevision: HEAD
    path: roles/$cluster_role/crossplane/resources
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

cp deploy-templates/default-values.yaml deploy-files/default-values.yaml
cp deploy-templates/$cluster_role-values.yaml deploy-files/$cluster_role-values.yaml
mkdir deploy-files/resources
cp deploy-templates/resources/* deploy-files/resources/*
