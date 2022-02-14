setup ACM resources


The steps are described here:

https://rcarrata.com/openshift/argo-and-acm/


taken from the blog you see the 4 important Elements: ManagedClusterSet, ManagedClusterSetBinding, Placement, GitOpsCluster

all needs to be configured properly before you can work with ApplicationSets


```
apiVersion: cluster.open-cluster-management.io/v1alpha1
kind: ManagedClusterSet
metadata:
  name: all-openshift-clusters
  spec: {}
```

Add the managed clusters as imported clusters into the ClusterSet. You can imported with the ACM Console or with the CLI:
Add Imported clusterset with Console

Add Imported clusterset with CLI

Create managed cluster set binding to the namespace where Argo CD or OpenShift GitOps is deployed.
cat managedclustersetbinding.yaml

```
apiVersion: cluster.open-cluster-management.io/v1alpha1
kind: ManagedClusterSetBinding
metadata:
  name: all-openshift-clusters
  namespace: openshift-gitops
spec:
  clusterSet: all-openshift-clusters
```

oc apply -f managedclustersetbinding.yaml
In the namespace that is used in managed cluster set binding, create a placement custom resource to select a set of managed clusters to register to an ArgoCD or OpenShift GitOps operator instance:
apiVersion: cluster.open-cluster-management.io/v1alpha1

```
kind: Placement
metadata:
  name: all-openshift-clusters
  namespace: openshift-gitops
spec:
  predicates:
  - requiredClusterSelector:
      labelSelector:
        matchExpressions:
        - key: vendor
          operator: "In"
          values:
          - OpenShift
```

NOTE: Only OpenShift clusters are registered to an Argo CD or OpenShift GitOps operator instance, not other Kubernetes clusters.

Create a GitOpsCluster custom resource to register the set of managed clusters from the placement decision to the specified instance of Argo CD or OpenShift GitOps:


```
apiVersion: apps.open-cluster-management.io/v1alpha1
kind: GitOpsCluster
metadata:
  name: argo-acm-clusters
  namespace: openshift-gitops
spec:
  argoServer:
    cluster: local-cluster
    argoNamespace: openshift-gitops
  placementRef:
    kind: Placement
    apiVersion: cluster.open-cluster-management.io/v1alpha1
    name: all-openshift-clusters
    namespace: openshift-gitops
```    