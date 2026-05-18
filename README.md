# psk-platform-ext-crossplane

This pipeline deploys two Argo Applications. In SyncWave 0, Crossplane itself is deployed, without any providers or other specific configurations. In SyncWave 1, the psk-crossplane-resource Helm chart is used to make those customizations.  

Obviously, as this is an AWS implementation, we need to in tall AWS providers. Crossplane will provide the general on-cluster ability tfor developers to provision specific paltform-supported AWS resources,and we'd like to use it where appropriate to assist in managing other platform services or extensions. For example, we will use cert-manager and external-dns as part of the istio implementation. Those extensions need eks-pod-identities that grant permissions to interact with Route53. But of course, before Crossplane can provision things it needs permission to do so. We need to first have a Role that the Crossplane provider can use to interact with the AWS api.  

As a general role used in all the clusters, the `PSKCrossplaneProviderRole` was created in each account in the psk-aws-iam-profiles pipeline. This role was then used to define an `"aws_eks_pod_identity_association" "crossplane_provider"`, created during the EKS provisioning in the psk-aws-platform-control-plane-base pipeline.  

Deployment structure diagrams.
```mermaid
---
title: The necessary bootstrap dependency for crossplane, before deploying to the control plane, was added in the earlier pipelines
---
flowchart LR

    IAMPROFILES@{ shape: das, label: "psk-aws-iam-profiles pipeline" }
    BASE@{ shape: das, label: "psk-aws-control-plane-base pipeline" }

    subgraph AWS Account
        ROLE[PSKCrossplaneProviderRole]
        ASSOC[eks-pod-identity-assoc]
    end

    SA@{ shape: brace-l, label: "sa: upbound-provider-family-aws" }

    IAMPROFILES --> ROLE
    BASE --> ASSOC
    ASSOC -.- SA
```
Once the family provider has access, we can now use crossplane capabilities directly to create additionl eks-pod-identity associations as needed.  
```mermaid
---
title: Crossplane deployment configuration
---
flowchart LR

    subgraph AWS Account
        subgraph EKS Control Plane
            subgraph ns:crossplane-system
                CP[Crossplane]
                PRO@{ shape: procs, label: "AWS providers"}
                COMP@{ shape: procs, label: "compositions, xdr, etc"}
            end
        end
    end
    subgraph psk-aws-control-plane-configuration
        AOA["roles/.../crossplane/"]
        AOAAWS["roles/.../crossplane-aws/"]
    end

    APPCP@{ shape: brace-r, label: "Application def: crossplane" }
    APPAWS@{ shape: brace-r, label: "Application def: crossplane-aws" }

    APPCP --> AOA --> |syncwave 0| CP
    APPAWS --> AOAAWS -- syncwave 1 --> PRO & COMP

    linkStyle 0 stroke:#306F00,stroke-width:3px,stroke-dasharray:5 5
    linkStyle 1 stroke:#306F00,stroke-width:3px

    linkStyle 2 stroke:#A06DA0,stroke-width:3px,stroke-dasharray:5 5
    linkStyle 3 stroke:#A06DA0,stroke-width:3px
    linkStyle 4 stroke:#A06DA0,stroke-width:3px
```

The initial providers installed provide support for eks changes, including creating eks-pod-identities when needed to other extensions:  
* provider-family-aws
* provider-aws-iam
* provider-aws-eks

Initial installed Functions:
* function-patch-and-transform
* function-go-templating
* function-extra-resources

As initially installed, crossplane is restricted from use to only cluster-administrators. This enables cluster configuration management to make use of crossplane features to provide capabilities for the control plane and for future developer "Users." THe future platform-provided infrastructure will make use of Crossplane Compositions to provider Developer access to infrastructure. In this way, crossplane can provision and maintain infrastructure on the developers behalf, subject to any policies or guardrails, and without needing to provider direct Developer access to crossplane operator capabilities.  

## Developer facing capabilities

_pending_  

## maintainers

to add a provider or function, modify the aws-default-values.yaml in the local `deploy-templates` folder.  
```yaml

providers:
  packages:
    - xpkg.upbound.io/upbound/provider-family-aws:v2.5.3
    - xpkg.upbound.io/upbound/provider-aws-iam:v2.5.3
    - xpkg.upbound.io/upbound/provider-aws-eks:v2.5.3

function:
  packages:
    - xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.10.4
    - xpkg.upbound.io/crossplane-contrib/function-go-templating:v0.12.0
    - xpkg.crossplane.io/crossplane-contrib/function-extra-resources:v0.3.0
```
