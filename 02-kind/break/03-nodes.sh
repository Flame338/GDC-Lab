#!/usr/bin/env bash
# Break 3. Scaling up does not work.
set -euo pipefail
for n in $(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o name); do kubectl cordon "${n#node/}" >/dev/null; done
kubectl scale deploy/web --replicas=4 >/dev/null
echo "Broken. Symptom: you asked for 4 replicas and two stay Pending. Why, and what is the least risky fix?"
