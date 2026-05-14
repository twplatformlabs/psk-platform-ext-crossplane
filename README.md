# psk-platform-ext-crossplane




# adding AWS provider packakges

Modify the `deploy-templates/default-values.yaml` to include additional packages, functions, etc  
```yaml
...
provider:
  # -- A list of Provider packages to install.
  packages:
    - xpkg.upbound.io/upbound/provider-family-aws:v2.5.3
    - xpkg.upbound.io/upbound/provider-aws-iam:v2.5.3
    - xpkg.upbound.io/upbound/provider-aws-eks:v2.5.3

configuration:
  # -- A list of Configuration packages to install.
  packages: []

function:
  # -- A list of Function packages to install
  packages:
    - xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.10.4
    - xpkg.upbound.io/crossplane-contrib/function-go-templating:v0.12.0
...
```

Then, add a DeploymentRuntimeConfig and ImageConfig for the package to `deploy-templates/resources/serviceaccounts.yaml`. This sets the provider package serviceaccount name to be predictable rather than with a serialized postfix number attached. Below is an example for the upbound-provider-aws-eks.  
```yaml
# upbound-provider-aws-eks
---
apiVersion: pkg.crossplane.io/v1beta1
kind: DeploymentRuntimeConfig
metadata:
  name: runtime-upbound-provider-aws-eks
spec:
  serviceAccountTemplate:
    metadata:
      name: upbound-provider-aws-eks

---
apiVersion: pkg.crossplane.io/v1beta1
kind: ImageConfig
metadata:
  name: runtime-upbound-provider-aws-eks
spec:
  matchImages:
    - prefix: xpkg.upbound.io/upbound/provider-aws-eks
  runtime:
    configRef:
      name: runtime-upbound-provider-aws-eks
```

And finally, add a CrossplanePodIdentityAssociation to `deploy-templates/resources/pod-identity-associations.yaml` for the serviceaccount so that it will be assigned the PSKCrossplaneProvderRole to enable it to provision AWS resources. Below is the upbound-provider-aws-eks example:  
```yaml
---
apiVersion: platform.io/v1alpha1
kind: CrossplanePodIdentityAssociation
metadata:
  name: crossplane-provider-eks
spec:
  serviceAccount: provider-aws-eks
  namespace: crossplane-system
```