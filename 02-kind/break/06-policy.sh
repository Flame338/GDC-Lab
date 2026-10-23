#!/usr/bin/env bash
# Break 6. Only some clients can reach the app.
set -euo pipefail
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: web-lockdown}
spec:
  podSelector: {matchLabels: {app: web}}
  policyTypes: [Ingress]
  ingress:
    - from: [{podSelector: {matchLabels: {role: frontend}}}]
YAML
echo "Applied. Prediction first: will a plain busybox pod still reach http://web on kind's default CNI? Test it, then explain the result."
