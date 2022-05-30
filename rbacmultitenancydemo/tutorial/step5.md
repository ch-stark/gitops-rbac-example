finally create the ApplicationSets


```
oc apply -f argo-apps
[cstark@cstark gitops-rbac-example]$ oc apply -f acm-setup/
gitopscluster.apps.open-cluster-management.io/argo-acm-clusters created
gitopscluster.apps.open-cluster-management.io/argo-acm-clusters created
gitopscluster.apps.open-cluster-management.io/argo-acm-clusters created
gitopscluster.apps.open-cluster-management.io/policies created
W0215 09:39:10.738871 1063931 warnings.go:67] cluster.open-cluster-management.io/v1beta1 ManagedClusterSet is deprecated; use cluster.open-cluster-management.io/v1beta1 ManagedClusterSet
W0215 09:39:10.846889 1063931 warnings.go:67] cluster.open-cluster-management.io/v1beta1 ManagedClusterSet is deprecated; use cluster.open-cluster-management.io/v1beta1 ManagedClusterSet
managedclusterset.cluster.open-cluster-management.io/all-openshift-clusters created
managedclustersetbinding.cluster.open-cluster-management.io/all-openshift-clusters created
managedclustersetbinding.cluster.open-cluster-management.io/all-openshift-clusters created
managedclustersetbinding.cluster.open-cluster-management.io/all-openshift-clusters unchanged
managedclustersetbinding.cluster.open-cluster-management.io/all-openshift-clusters created
placement.cluster.open-cluster-management.io/dev1 created
placement.cluster.open-cluster-management.io/dev2 created
placement.cluster.open-cluster-management.io/policies created
placement.cluster.open-cluster-management.io/defaultplacement created

```

Vefify in ACM console (login as kube-admin)  that all Applications have been successfully applied