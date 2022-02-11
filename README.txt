Goal of this repo is to show Configuration-Options for RBAC when integration Gitops-Operator using Applicationsets with RHACM.

a certain user should have all permissions
a certain user should have readpermissions on one project
a certain user should have admin-permissions on one project
a certain user should have admin-permissions on one project

currently we use all Clusters and don't configure different-clustersets


# gitops-rbac-example

A: Policies:

1. Install-Operator
2. Configure-ArgoCD (rbac: policy: g, system:cluster-admins, role:admin, role:SreAdminGrp)
3. Setup-Groups (SreAdminGrp, AppX-AdminGrp, AppX-ViewGrp, AppY-AdminGrp, AppY-ViewGrp)


# This Policy considers the following example scenario
#   Two different applications  X and Y are running on the Cluster.
#   Application X is deployed in namespace dev1
#   Application Y is deployed in namespace dev2
#
# This Policy Configures the following rbac model for the above scenario
#   UsersGroups:  SreAdminGrp, Developers, AppX-AdminGrp, AppX-ViewGrp, AppY-AdminGrp, AppY-ViewGrp
#   Rolebindings:
#       SreAdminGrp has cluster-admin access to the Cluster
#       AppX-AdminGrp has admin access to the namespace dev1 where AppX is deployed
#       AppX-ViewGrp has view access to the namespace dev1 where AppX is deployed
#       AppY-AdminGrp has admin access to the namespace dev2 where AppY is deployed
#       AppY-ViewGrp has view access to the namespace dev2 where AppY is deployed



HTPassword Authentication
users: #Users: clusteradminuser, devuser1, devuser2, devuser3, adminuser, adminuser2)
groups: (#UsersGroups: SreAdminGrp, AppX-AdminGrp, AppX-ViewGrp, AppY-AdminGrp, AppY-ViewGrp)

SreAdminGrp: ClusterAdmin
admins
AppX-AdminGrp is part of admins
AppY-AdminGrp is only admin for namespace dev2
developer
ocp-developer is part of developer
viewer
apps-viewer is part of viewer

ClusterRole/Role Bindings setup
SreAdminGrp group has cluster-admin on OpenShift

The AppX-AdminGrp group has edit on the dev1,dev2 namespace on OpenShift
The AppY-AdminGrp group has edit on the dev2 namespace on OpenShift




ArgoCD Configurations

ArgoCD is integrated with the OpenShift oAuth
RBAC Policy
The admins OpenShift group is set up as ArgoCD admins
The developer OpenShift group is set up as ArgoCD users
ArgoCD admins can see and sync all ArgoCD Applications
The cluster-config ArgoCD project has all "cluster wide" configurations
Can only be seen/synced by ArgoCD admins
The pricelist ArgoCD project has all appliaction components to run the Pricelist application
Can be seen/synced by ArgoCD admins or ArgoCD users
Autosync is turned on



















B: openshift-setup

1. Create users
2. Create groups and map-users (#UsersGroups:  SreAdminGrp, AppX-AdminGrp, AppX-ViewGrp, AppY-AdminGrp, AppY-ViewGrp


C: Setup Roles

namespaces:
openshift-gitops (cluster-admin-tasks,SreAdminGrp)
dev1 (AppX-AdminGrp, AppX-ViewGrp)  
dev2 (AppY-AdminGrp, AppY-ViewGrp)

D: argo-projects

1. default-project  namespace: openshift-gitops
2. dev1 project   namespace: dev1
3. dev2 project   namespace: dev2

E: acm-gitops

gitopscluster 
1: default namespace: openshift-gitops
2. dev1  namespace: dev1
3. dev2  namespace: dev2

bindings 
1. default  namespace: openshift-gitops
2. dev1  namespace: dev1
3. dev2  namespace: dev2

F: application-sets

1. default  references default-appproject namespace: openshift-gitops
2. dev1 references dev1-appproject namespace: dev1
3. dev2 references dev2-appproject namespace: dev2




rhacm-rbac

todo







