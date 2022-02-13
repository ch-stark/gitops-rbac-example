#create a list of users and print password


SECRET=htpass-secret-xxx
PASSWORD=$RANDOM%

echo $PASSWORD


htpasswd -c -b -B htpasswd rootadmin ${PASSWORD}
htpasswd -b -B htpasswd admin ${PASSWORD}

htpasswd -b -B htpasswd john ${PASSWORD}
htpasswd -b -B htpasswd paul ${PASSWORD}
htpasswd -b -B htpasswd ringo ${PASSWORD}
htpasswd -b -B htpasswd george ${PASSWORD}
htpasswd -b -B htpasswd pete ${PASSWORD}

htpasswd -b -B htpasswd andrew ${PASSWORD}
htpasswd -b -B htpasswd karla ${PASSWORD}
htpasswd -b -B htpasswd marina ${PASSWORD}

htpasswd -b -B htpasswd user1 ${PASSWORD}
htpasswd -b -B htpasswd user2 ${PASSWORD}
htpasswd -b -B htpasswd user3 ${PASSWORD}

htpasswd -b -B htpasswd dev1 ${PASSWORD}
htpasswd -b -B htpasswd dev2 ${PASSWORD}
htpasswd -b -B htpasswd dev3 ${PASSWORD}

htpasswd -b -B htpasswd ops1 ${PASSWORD}
htpasswd -b -B htpasswd ops2 ${PASSWORD}
htpasswd -b -B htpasswd ops3 ${PASSWORD}

htpasswd -b -B htpasswd manager1 ${PASSWORD}
htpasswd -b -B htpasswd manager2 ${PASSWORD}
htpasswd -b -B htpasswd manager3 ${PASSWORD}

htpasswd -b -B htpasswd viewer1 ${PASSWORD}
htpasswd -b -B htpasswd viewer2 ${PASSWORD}
htpasswd -b -B htpasswd viewer3 ${PASSWORD}


htpasswd -b -B htpasswd dev ${PASSWORD}
htpasswd -b -B htpasswd qua ${PASSWORD}
htpasswd -b -B htpasswd prd ${PASSWORD}


cat htpasswd | base64 -w 0

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

EOF

oc apply -f ${SECRET}.yaml
