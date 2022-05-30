OpenShift-Setup

1. Setup HTPasswd with some dummy-users (we create quite a lot of users for flexibility, adjust users and password for your purpose)
   by executing `sh createorupdatehtpasswd.sh`

    ```
    SECRET=htpass-secret-xxx


    cat << EOF >${SECRET}.yaml

    apiVersion: v1
    kind: Secret
    metadata:
    name: htpass-secret
    namespace: openshift-config
    annotations:
        argocd.argoproj.io/sync-options: Prune=false
        argocd.argoproj.io/compare-options: IgnoreExtraneous
    data:
    htpasswd: $(cat htpasswd | base64 -w 0)
    type: Opaque


    oc apply -f ${SECRET}.yaml

    2. Setup HTPasswd-Provider
    3. review roles, rolebindings.yaml
    ```

    execute Files.
    ```
    secret/htpass-secret created
    group.user.openshift.io/SreAdminGrp created
    group.user.openshift.io/Developers created
    group.user.openshift.io/AppX-AdminGrp created
    group.user.openshift.io/AppY-AdminGrp created
    group.user.openshift.io/AppX-ViewGrp created
    group.user.openshift.io/AppY-ViewGrp created
    group.user.openshift.io/Manager created
    group.user.openshift.io/QA created
    Warning: oc apply should be used on resource created by either oc create --save-config or oc apply
    oauth.config.openshift.io/cluster configured
    clusterrolebinding.rbac.authorization.k8s.io/sreadmingroup created
    rolebinding.rbac.authorization.k8s.io/example-rolebinding created
    rolebinding.rbac.authorization.k8s.io/argo-ns-full created
    rolebinding.rbac.authorization.k8s.io/argo-ns-full created
    rolebinding.rbac.authorization.k8s.io/dev1developer created
    clusterrole.rbac.authorization.k8s.io/argo-cluster-read created
    role.rbac.authorization.k8s.io/argo-ns-full created
    role.rbac.authorization.k8s.io/argo-ns-full created
    ```



Later the files could be converted into a ACM-Policy but monitoring, compliance purposes.