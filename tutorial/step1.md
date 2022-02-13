
1. Assuming you have a ACM 2.4/2.5 Hub-Cluster installed
   Label the Hub-Cluster with the following (environement=dev):

    clusterSelector:
        matchExpressions:
        - key: environment
            operator: In
            values:
            - "dev"

2. create a namespace policies and execute the two policies to setup-gitops-operator            
  
   oc apply -f policies 