
### Goal of this repo is to show Configuration-Options for RBAC when integration Gitops-Operator using Applicationsets with RHACM.

usecases:

* a certain user should have all permissions for all Applications and Cluster-Admin-Tasks
* a certain user should have readpermissions on one project/Application
* a certain user should have admin-permissions on one project
* a certain user should have admin-permissions on all projects but not cluster-admin-rights
* it should show the diffent options regarding RBAC-Configuration
* a certain user should only see namespaces in a certain ClusterSet
.....


todo:

gatekeeper-integration,
namespace-operator
external-secrets
integrity-shield
groupsync-operator

....
currently we use all Clusters and don't configure Specific-Clustersets
Later some Applicationsets will be extended to target several clusters.
Some Applications like Policies can only be generated on the Hub-Cluster


#### Some links this tuturial will be based on:

1. https://github.com/christianh814/openshift-cluster-config
2. Security-Features we get with ArgoCD (https://rcarrata.com/openshift/secure-argo-supply-chain/)


### Installation (a tutorial will be provided)

A: Policies (later we will convert more objects into Policies using PolicyGenerator)

1. Install-Gitops-Operator
2. Configure-ArgoCD (rbac: policy: g, system:cluster-admins, role:admin, role:SreAdminGrp)
   https://github.com/ch-stark/gitops-rbac-example/blob/main/policies/policy-config-operator-dex.yaml#L91


B: OpenShift-setup 

3. Setup-Groups (SreAdminGrp, AppX-AdminGrp, AppX-ViewGrp, AppY-AdminGrp, AppY-ViewGrp, Developers)

   Setup HTPassword Authentication


C: argo-projects

1. default-project  namespace: openshift-gitops
2. dev1 project   namespace: dev1
3. dev2 project   namespace: dev2
4. policies project namespace: policies


E: acm-gitops

gitopscluster 
1: default namespace: openshift-gitops
2. dev1  namespace: dev1
3. dev2  namespace: dev2
4. policies namespace: policies

bindings 
1. default  namespace: openshift-gitops
2. dev1  namespace: dev1
3. dev2  namespace: dev2
3. policies  namespace: policies

F: application-sets

1. default  references default-appproject namespace: openshift-gitops
2. dev1 references dev1-appproject namespace: dev1
3. dev2 references dev2-appproject namespace: dev2
4. policies references policies-appproject namespace: policies


