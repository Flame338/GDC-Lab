#!/usr/bin/env bash
# Break 4. A pod keeps restarting.
set -euo pipefail
kubectl run hog --image=polinux/stress --restart=Always \
  --overrides='{"spec":{"containers":[{"name":"hog","image":"polinux/stress","command":["stress","--vm","1","--vm-bytes","150M","--vm-hang","1"],"resources":{"limits":{"memory":"100Mi"}}}]}}' >/dev/null
echo "Broken. Symptom: pod 'hog' restarts over and over. Name the exact reason Kubernetes gives, and where you found it."
