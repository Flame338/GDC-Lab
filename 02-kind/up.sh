#!/usr/bin/env bash
# Create the cluster (once) and deploy the baseline app.
set -euo pipefail
cd "$(dirname "$0")"
kind get clusters | grep -qx gdc-lab || kind create cluster --config kind-config.yaml
kubectl config use-context kind-gdc-lab
kubectl apply -f app/app.yaml
kubectl rollout status deploy/web --timeout=120s
kubectl run probe --rm -i --restart=Never --image=busybox:1.36 -- wget -qO- http://web | head -4
echo "Baseline is healthy. Pick a break: ls break/"
