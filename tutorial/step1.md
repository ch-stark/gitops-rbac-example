
1. Assuming you have a ACM 2.4/2.5 Hub-Cluster installed on OpenShift 4.9
   Label the Hub-Cluster with the following (environement=dev):

    clusterSelector:
        matchExpressions:
        - key: environment
            operator: In
            values:
            - "dev"

2. create a namespace policies and execute the two policies to setup-gitops-operator            
  
    ```
    oc apply -f policiesgenerated/
    project.project.openshift.io/dev1 created
    project.project.openshift.io/dev2 created
    project.project.openshift.io/prod created
    project.project.openshift.io/qa created
    project.project.openshift.io/policies created
    policy.policy.open-cluster-management.io/policy-config-argocd-dex created
    placementbinding.policy.open-cluster-management.io/binding-policy-config-argocd-dex created
    placementrule.apps.open-cluster-management.io/placement-policy-config-argocd-dex created
    policy.policy.open-cluster-management.io/policy-gitops-operator-nondef created
    placementbinding.policy.open-cluster-management.io/binding-policy-gitops-operator-nondef created
    placementrule.apps.open-cluster-management.io/placement-policy-gitops-operator-nondef created
    ```

3. Verify policies are compliant and that Operator has been installed   