Goal of this repo is to show Configuration-Options for RBAC


# gitops-rbac-example


A: Policies:

1. Install-Operator
2. Configure-ArgoCD
3. Setup-Groups (SreAdminGrp, AppX-AdminGrp, AppX-ViewGrp, AppY-AdminGrp, AppY-ViewGrp)

B: openshift-setup

1. Create users
2. Create groups and map-users (#UsersGroups:  SreAdminGrp, AppX-AdminGrp, AppX-ViewGrp, AppY-AdminGrp, AppY-ViewGrp
#Users: 
#clusteradminuser
#devuser2
#devuser1
#adminuser
#adminuser2)

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







