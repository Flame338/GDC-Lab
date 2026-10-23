#!/usr/bin/env bash
# Break 5. Names stop resolving. (You have seen this one at home.)
set -euo pipefail
kubectl -n kube-system scale deploy/coredns --replicas=0 >/dev/null
echo "Broken. Symptom: 'wget http://web' from a fresh pod fails, but 'wget http://<pod IP>' works. Why?"
