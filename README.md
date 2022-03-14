
### Goal of this repo is to show Configuration-Options for RBAC when integration Gitops-Operator using Applicationsets with RHACM.

usecases:

* a certain user should have all permissions for all Applications and Cluster-Admin-Tasks
* a certain user should have readpermissions on one project/Application
* a certain user should have admin-permissions on one project
* a certain user should have admin-permissions on all projects but not cluster-admin-rights
* it should show the diffent options regarding RBAC-Configuration
* a certain user should only see namespaces in a certain ClusterSet
* we will deploy 4 Applications. One for Cluster-Admin-Tasks and bootstrapping, one for Policies and 2 for Apps
* deployment of Helm-Charts
.....


todo: Integration of several other features.

`gatekeeper`,
`namespace-operator`,
`external-secrets/vault`,
`integrity-shield`,
`groupsync-operator`,
`policy-generator`,
`monitoring`,
`argocd-notifications`
`
 `

....

currently we use all Clusters and don't configure Specific-Clustersets
Later some Applicationsets will be extended to target several clusters.
Some Applications like Policies can only be generated on the Hub-Cluster


#### Some links this tuturial will be based on:

1. https://github.com/christianh814/openshift-cluster-config
2. Security-Features we get with ArgoCD (https://rcarrata.com/openshift/secure-argo-supply-chain/)
3. https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.4/html/applications/index
4. https://github.com/stolostron/policy-collection/issues/217
5. https://github.com/tosin2013/acm-multi-cluster-argocd-dashboard
6. https://github.com/joatmon08/vault-argocd
7. https://cloud.redhat.com/blog/openshift-authentication-integration-with-argocd
8. https://cloud.redhat.com/blog/openshift-pipelines-and-openshift-gitops-are-now-generally-available
9. https://www.opensourcerers.org/2022/03/07/oops-something-is-wrong-with-your-gitops-application/

### Installation (a tutorial will be provided)


A: Policies (later we will convert more objects into Policies using PolicyGenerator)

1. Install-Gitops-Operator
2. Configure-ArgoCD (rbac: policy: g, system:cluster-admins, role:admin, role:SreAdminGrp)
   https://github.com/ch-stark/gitops-rbac-example/blob/main/policies/policy-config-operator-dex.yaml#L91


B: OpenShift-setup 

1. Setup-Groups (SreAdminGrp, AppX-AdminGrp, AppX-ViewGrp, AppY-AdminGrp, AppY-ViewGrp, Developers)

2. Setup HTPassword Authentication


C: argo-projects

1. default-project  namespace: openshift-gitops
2. dev1 project   namespace: dev1
3. dev2 project   namespace: dev2
4. policies project namespace: policies
5. ArgoCD-Configuration ConfigMap and ConfigMapRBAC


E: acm-gitops

gitopscluster:

1. default namespace: openshift-gitops
2. dev1  namespace: dev1
3. dev2  namespace: dev2
4. policies namespace: policies

bindings:

1. default  namespace: openshift-gitops
2. dev1  namespace: dev1
3. dev2  namespace: dev2
3. policies  namespace: policies


F: application-sets

1. default  references default-appproject namespace: openshift-gitops
2. dev1 references dev1-appproject namespace: dev1
3. dev2 references dev2-appproject namespace: dev2
4. policies references policies-appproject namespace: policies


Placements

So far we just place all on Hub-Cluster, will be extended
