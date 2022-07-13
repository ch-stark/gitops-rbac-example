## Configuration Options regarding Multi-Tenancy and RBAC when using GitopsOperator, ApplicationSets, and RHACM


Starting with RHACM 2.5 ApplicationSets have become GA and are ready to use in production.
Starting with GitopsOperator 1.6 ApplicationSets are also GA from an OpenShift Gitops-Operator point of view.
This blog provides an overview of available configuration options and best practices for Cluster- and Multicluster Multi-Tenancy.
Sharing clusters saves costs and simplifies administration. However, sharing clusters also present challenges such as security, fairness, and managing noisy neighbors. 
Clusters can be shared in many ways. In some cases, different applications may run in the same cluster. 
In other cases, multiple instances of the same application may run in the same cluster, one for each end-user.

If you check the following part from Kubernetes-Documentation on [Multi-Tenancy](https://kubernetes.io/docs/concepts/security/multi-tenancy/) 
this is already good info if you have a Single Cluster. This blog will enhance this to a Multi-Cluster fleet. Later in this blog we will also introduce Kyverno
which gives us some aid to ensure that Tenants are separated from each other.


## Organizational Needs


There are all sorts of different models that customers use and which are driven by their organizational needs. Historically OpenShift has been using a shared cluster model much more commonly than is seen in kubernetes since we had RBAC way before k8s did and provide more features around security to make this work. Many customers operate shared clusters, typically the OOTB recommendation is to start with three clusters (lab, non-prod and prod) with applications teams having their own dev/test/tools namespaces on non-prod and pre-prod/prod namespaces on the prod cluster.
Having said that in reality it varies a lot, it's largely driven by the organizational structure but other factors come into play. You are more likely to see dedicated team clusters in the public cloud than on-prem, in on-prem it’s more rare to see dedicated team clusters. A huge amount of customers have shared clusters everywhere, clusters might be expensive in terms of infra (control plane and infra nodes) and it doesn't make sense to have a cluster to only support a couple of applications.

There might be teams that deploy team scoped instances that manage the teams’ namespaces across multiple clusters since they want teams to have a single pane of glass. 
Other organizations might be way more siloed in terms of non-prod and prod and prefer separate GitOps instances for each.

Some customers strongly argue to give the teams more freedom simply because else a Cluster-Administrator might be overwhelmed by all different kinds of requests.

When discussing a MultiCluster Multi-Tenancy approach let’s first discuss the following question which are mainly Organization considerations.:

* How many teams will work on the Clusters?  How independent are the teams, are teams maybe different external customers?

* What will be the different roles that a team has? E.g. Will governance be done by a Cluster-Fleet admin, or on a team level?

* Who will be allowed to create Clusters? Only the Cluster-Admin or also Team-admins?

* Will the teams work completely independently, are there some shared resources like Dev-Clusters?

* Should a team work on their own Clusters or group of Clusters? Or should teams work on all clusters separated by namespaces?
  How to configure if option 1?
  How to configure if option 2?

* Should teams work directly on Managed-Clusters or should they all do that through the Hub-Cluster?  
      
* Should Cluster-Admins be disallowed on ManagedClusters?
      
* Who and what can be done on the Hub-Cluster by non Cluster-Admins?
       
* Should there be namespaces that are shared between different Clusters? 
      
* Who is allowed to create namespaces on the Hub/Managed-Clusters? 
    
* Should Gitops be used and how are the permissions in git-handled? 

* Should certain resources be excluded in git?   


To go one step back we can identify three common patterns when handling Applications in MultiClusterEnvironments:

## Patterns:

### Pattern 1:  Have Multi-Tenancy on ClusterLevel and use the same Configuration of a Single-Cluster for the whole fleet of Clusters.

This means a Hub and Spoke model where all the Hub does is push out team-scoped GitOps instances for the teams to use along with any other cluster-scoped resources they require (operators for example). Teams will have namespace admin access to those instances and to the clusters/namespaces, those instances manage. What visibility those team-scoped instances have (i.e. multiple namespaces on a single cluster, multiple namespaces across multiple clusters) is highly dependent on the type of organization and its structure. 
Some Customers deploy team scoped instances that manage the teams’ namespaces across multiple clusters since they want teams to have a single pane of glass. Other orgs might be way more siloed in terms of non-prod and prod and prefer separate GitOps instances for each.

### Pattern 2:  Separate Teams so that each team only has access to Clusters of its ClusterSets

You basically just ensure that a Cluster-Admin of ClusterSet 1  has in no way can access on resources on ClusterSet 2.

### Pattern 3:  Use a mix of 1 to 2. 

Customers want to separate Clusters but some namespaces should still be shared. Some namespaces might be global.

The blog tries to answer some questions by showing the different configuration options.
While we will provide some guidelines and recommendations we also explain how the setup could be changed.


## RHACM Personas

It is recommended - when working with RHACM -  to develop a blueprint regarding the different Roles which are working with ACM.  At the following we would like to give some guidelines knowing that especially in smaller teams those roles might be implemented by a smaller number of real persons.

It needs to be mentioned that even if you have defined the Personas it needs to be clarified that the implemented Cluster-Roles can certainly differ a lot so we will at the end only have some suggestions.


### RHACM-Cluster-Admin

This RHACM-Cluster-Admin has all rights to do whatever you can configure in ACM.
It is similar to a Cluster-Admin with some  restrictions

You can see the ClusterRole granting RHACM Cluster-Admin rights:

https://github.com/ch-stark/gitops-rbac-example/blob/main/clusterroles/rhacm-cluster-admin.yaml

### IT Operations

This team might have the following questions and tasks:

How can I manage the lifecycle of multiple clusters regardless of where they reside using a single control plane?
How can I quickly get to the root cause of failed components?
How do I monitor usage across multiple clouds?
How do I automate provisioning and deprovisioning of my clusters?

You might decide if IT-Operations has the permissions to create Clusters only in Certain-Clustersets as you see here:

## SRE/DevOps

This team might have the following questions and tasks:
How do I get a simplified understanding of my cluster health and the impact on my application availability?”
“How do I automate provisioning and destroying of my clusters, workload placement based on capacity and policies, and the pushing of applications from dev to prod?

Again this ClusterRole [https://github.com/ch-stark/gitops-rbac-example/blob/main/rbacmultitenancydemo/redteamadmin/redteamadminclusterrole.yaml] 
might be an example to start:

### SecOps

How do I ensure all my clusters are compliant with my defined policies?”

“How do I set consistent security policies across diverse environments and ensure enforcement?”
“How do I get alerted on any configuration drift and remediate it?”

So SecOps might need to see all Policies, you might decide if SecOps can generate Policies for all Clusters or only for Clusters in certain ClusterSets.

Now as we introduced the possible teams - and before technically implementing their ClusterRoles - let’s explain some RHACM concepts which are relevant for later. 


## RHACM Concepts for MultiCluster-Multitenancy

In the following we are quickly describing some ACM concepts and objects which are relevant for the later implementation.

### ClusterSets 

This concept - which is also used within Submariner - adds Clusters to certain groups.  By default, the local cluster is part of the default ClusterSet. One Cluster currently can only be part of a single ClusterSet. A Cluster must be part of a ClusterSet so that you can deploy to. We will explain this later.

### ManagedClusterSetBindings  

A  ManagedClusterSetBinding binds a namespace to a ClusterSet. You can also bind a namespace to several ClusterSets by creating a binding for each ClusterSet

### Placements

A Placement looks for ManagedClusterSetBinding in a namespace.

You can either just use a label and it will deploy on all Clusters which are bound to the namespace and which match the condition.
Or you can assign a ClusterSet to the Placement to ensure the Apps/Policies are only 

*! Please note that in  ACM 2.5 every Cluster can only be part of a ClusterSet, this might change in future versions



### Rephrasing questions including ACM/OpenCluster-Management Concepts

After we have described the basic concepts now let’s rephrase some of the initial questions using RHACM terminology:

* Should every Team or Customer get its own ClusterSet?  
* How to guarantee that Team 1 can not get any information about Clusters and Applications that Team 2 is hosting in its ClusterSet? 
* Should ACM delegate anything GitOps related to OpenShift GitOps and just be the single pane of glass for it given that Argo CD will always be
  partitioned into multiple instances?
* Can a Team Administrator create ACM-Policies which gives him basically Cluster-Admin rights? 
* If yes, should he only be able to use only the new PlacementAPI to ensure it is only deployed to a certain ClusterSet?
* Should we disallow a Team Administrator to not create PlacementRules?
* How to ensure that this works both from Git, UI and Cli?
* Should a user be able to create a Placement that must point to a ClusterSets or can the Placement select Clusters from different ClusterSets and you
  select Clusters by labels?  


### Relevant ClusterRoles for MultiClusterManagement

From an RBAC and Role/ClusterRole point of view, the biggest issue is handling all objects properly
That fall under:
- apiGroups:
  - cluster.open-cluster-management.io

You can see the https://github.com/ch-stark/gitops-rbac-example/blob/main/clusterroles/rhacm-cluster-admin.yaml role here.
For our usecase it is not enough as we need to also grant extra Permissions as we use Kyverno-Generate functionality which will be 
explained later


## Including Kyverno

Kyverno is a PolicyEngine which can be integrated with ACM via PolicyGenerator.
Please see existing examples and blogs:

https://kyverno.io/policies/
https://github.com/stolostron/policy-collection/tree/main/stable/CM-Configuration-Management
https://cloud.redhat.com/blog/generating-governance-policies-using-kustomize-and-gitops

During this blog Kyverno is used to support enforcing Access-Control.


### ACM Policies and Kyverno

Getting one more step towards integration we are deciding to create the following Policies which can be reviewed in this repository:

https://github.com/ch-stark/gitops-rbac-example/tree/main/rbacmultitenancydemo/kyverno/overlay/policies

* Based on this Policies  we are generating three PolicySets
  * ACM-Policies
  * Kyverno-Multitenancy-Hub-Side
  * Kyverno-Multitenancy-Client-Side


### Policies for the Hub-Side

* Every team gets a namespace on the hub where it can deploy Applications or ApplicationSets, the Policy controls that it must not deploy in other
  namespaces
* Team Admins can only create new namespaces when they deploy new Clusters. 
* A policy controls that only Cluster-Admins can create namespaces on the Hub.
* A policy controls that every team/customer has a ClusterSet.
* A policy controls that this ClusterSet admin can deploy Clusters only in its ClusterSet.
* A policy controls that an ApplicationSet admin can only deploy Apps to its ClusterSet.
* A policy controls that we don’t allow any ClusterAdmin on Managed-Clusters.


### Policies for Managed-Clusters

* Team admins can generate namespaces on Managed-Clusters but they need to follow certain patterns
* Those namespaces can also be created by deploying applicationsets.
* When you create a new namespace we expect that all resources are generated (roles, limitranges) 
* A team admin can generate ApplicatonSets in its namespace or in the shared namespace. On the Hub, the shared namespace is called SharedHub
  On the managed cluster it has the pattern shared*
* A team admin can generate namespaces (either via destination-namespace, or the namespaces in the objects only in Clusters of its ClusterSet)
* A team admin can generate an ArgoCD Application on the Hub to deploy Policies. But Policies can only have Placements and Placement must be the correct ClusterSet.


### Using PolicyGenerator and Kyverno

We use Kyverno to better ensure the Rules are working
We use PolicyGenerator to deploy Kyverno policies to the Hub or to the ManagedClusters.

### Integrating PolicyGenerator and ArgoCD

This Integration uses initContainers to add the  Policy Generator tool to thr ArgoCD-Repo server. See more information here: 
Custom tooling supported by Operator - https://github.com/argoproj-labs/argocd-operator/blob/master/docs/usage/customization.mdThi
See an example here (https://github.com/ch-stark/gitops-rbac-example/blob/main/rbacmultitenancydemo/argocds/policies-argocd.yaml#L6).
This approach is explained in more detail in this [blog](https://cloud.redhat.com/blog/generating-governance-policies-using-kustomize-and-gitops)

### Disable Templating

When you generate a ACM-Policy from a Kyverno-Policy it often does not work by default as you need to escape some expressions which might be processes by RHACM's
powerful templating langguage.
Therefor When using Kyverno as input for PolicyGenerator you can set the following property on a ACM policy to disable templating:

'policy.open-cluster-management.io/disable-templates'

You can achieve this again via Kyverno-Policy or via kustomize.yaml

```
kustomize.yaml

generators:
  - policyGenerator.yaml
commonAnnotations:
  policy.open-cluster-management.io/disable-templates: true
```

### Using PolicyGenerator with Placement

PolicyGenerator by default uses PlacementRules.

But it is easy to change, in the below example we set a Placement-Object which will be generated when running the example.

```
apiVersion: policy.open-cluster-management.io/v1
kind: PolicyGenerator
metadata:
  name: kyverno
policyDefaults:
  namespace: policies-appset
  remediationAction: enforce
  severity: medium
  placement:
    placementPath: placement.yaml
policies:
  - name: policy-generator-blog-kyverno
    manifests:
      - path: kyverno
```




## Run the Example

In the following wee have two teams:    

* TeamRed (has a TeamAdmin who can create Clusters. Has a AppDeployer and a Viewer)
* TeamBlue (has a TeamAdmin who cannot create Clusters but can deploy Applications and a Viewer)
* We expect that you have a ACM 2.5 Cluster.
* Run on the Hub
  * git clone https://github.com/ch-stark/gitops-rbac-example
  * execute 
    `cmd="oc apply -f gitopsdemoall.yaml"; for i in $(seq 2); do $cmd "count: $i"; sleep 30;done`

We need to grand the initial ArgoCD extended permission this is why we decided to assign `open-cluster-management:cluster-manager-admin`


It follows `Apps of Apps pattern` and it will set up the following for you:

Demo-Users/Groups  (red and blueteams, one sre and one viewer per team)
ClusterSets (redteam and blueteam, members of redsre become ClusterSet-Admin)
RedTeam-Admin,BlueTeam-Admin (can generate namespaces on the Hub and deploy Clusters and ApplicationSets)


After that, you can see all Apps in ArgoCD and in ACM


ACM view

![ACM view](images/viewargoinacm.png)


Argo View

![Argo View](images/argoview.png)


SRE-View on his ApplicationSet
![ApplicationSets](images/appset_sreview.png)


View for SRE/Viewer when no Cluster has been created. The ApplicationSet is visible, but not deployed to any cluster.


## Validating RBAC/Kyverno Rules from the UI


Try to create a Subscription


![Subscription not allowed](images/subscriptionnotallowed.png)


This will be prevented because the ClusterRole has not the necessary permissions.


Try to sync a Policy from Git which uses a PlacementRule

![Disallowplacementrules from Git](images/argocddisallowplacementrule.png)




** Kyverno-Checks

![Disallowplacementrules](images/disallowplacementrules.png)


```
status:
  conditions:
    - lastTransitionTime: '2022-07-12T11:10:29Z'
      message: >-
        Failed sync attempt to f5b757d3dd49d42bb66500f3401b51e0cab804f6: one or
        more objects failed to apply, reason: admission webhook
        "validate.kyverno.svc-fail" denied the request: 


        resource
        PlacementRule/policy-generator-blog/placement-policy-generator-blog-app
        was blocked due to the following policies


        disallow-placementrules:
          disallow-placementrules: Using Placement Rules not allowed (retried 5 times).
      type: SyncError
  health:
    status: Healthy
  operationState:
    finishedAt: '2022-07-12T11:10:29Z'
    message: >-
      one or more objects failed to apply, reason: admission webhook
      "validate.kyverno.svc-fail" denied the request: 
```

 


In the following check we have 3 violations:
* namespace does not match pattern
* AppProject does not match pattern
* Placement is not the Placement which has to be used.



![3 checks are failing](images/3validationfailures.png)

 

Kyverno validation while creating a Cluster


![create Cluster with wrong name](images/createClusterwrongname.png)


Certainly we also need to ensure that what we do from the UI also works from the command line.
Here you see some checks:


* Tests cli
 
  * Create NS with wrong pattern
 `oc create ns blueteam`
`
Error from server: admission webhook "validate.kyverno.svc-fail" denied the request: 
resource Namespace//blueteam was blocked due to the following policies
team-validate-red-ns-schema:
  namespace-name: 'validation failure: The only names approved for your namespaces
are the ones starting by redteam*'
`

* Create NS and validate that mutation has been added

```
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    openshift.io/sa.scc.mcs: s0:c32,c4
    openshift.io/sa.scc.supplemental-groups: 1001000000/10000
    openshift.io/sa.scc.uid-range: 1001000000/10000
    policies.kyverno.io/last-applied-patches: |
      add-labelsnamespace-redteam.add-labelsnamespace-redteam.kyverno.io: added /metadata/labels/argocd.argoproj.io~1managed-by
  labels:
    argocd.argoproj.io/managed-by: redteam
    kubernetes.io/metadata.name: redteamtest
  name: redteamtest
spec:
  finalizers:
  - kubernetes
status:
  phase: Active
```

Check generated ManagedClusterSetBinding and the generated Placement after a namespace has been created

``` 
apiVersion: v1
items:
- apiVersion: cluster.open-cluster-management.io/v1beta1
  kind: ManagedClusterSetBinding
  metadata:
    creationTimestamp: "2022-07-08T12:10:12Z"
    generation: 1
    labels:
      app.kubernetes.io/managed-by: kyverno
      kyverno.io/generated-by-kind: Namespace
      kyverno.io/generated-by-name: redteamtest
      kyverno.io/generated-by-namespace: ""
      policy.kyverno.io/gr-name: ur-w67jw
      policy.kyverno.io/policy-name: add-argocd-clusterrolebinding-red-all
      policy.kyverno.io/synchronize: enable
    name: redteam
    namespace: redteamtest
  spec:
    clusterSet: redteam
``` 

```
apiVersion: v1
items:
- apiVersion: cluster.open-cluster-management.io/v1beta1
  kind: Placement
  metadata:
    creationTimestamp: "2022-07-08T12:10:12Z"
    generation: 1
    labels:
      app.kubernetes.io/managed-by: kyverno
      kyverno.io/generated-by-kind: Namespace
      kyverno.io/generated-by-name: redteamtest
      kyverno.io/generated-by-namespace: ""
      policy.kyverno.io/gr-name: ur-w67jw
      policy.kyverno.io/policy-name: add-argocd-clusterrolebinding-red-all
      policy.kyverno.io/synchronize: enable
    name: redteam
    namespace: redteamtest
  spec:
    clusterSets:
    - redteam
``` 
 
 
## Closing words
 
 
This blog wanted to show some configuration options.  Keep it simple is the recommended practise to start with.
