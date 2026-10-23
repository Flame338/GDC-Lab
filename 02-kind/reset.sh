#!/usr/bin/env bash
# Undo every break and restore the baseline.
set -euo pipefail
cd "$(dirname "$0")"
for n in $(kubectl get nodes -o name); do kubectl uncordon "${n#node/}" >/dev/null; done
kubectl -n kube-system scale deploy/coredns --replicas=2 >/dev/null
kubectl delete deploy/web --ignore-not-found >/dev/null
kubectl delete pod hog --ignore-not-found >/dev/null
kubectl delete networkpolicy --all >/dev/null
kubectl apply -f app/app.yaml >/dev/null
kubectl rollout status deploy/web --timeout=120s
echo "Reset done."
