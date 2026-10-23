#!/usr/bin/env bash
# Break 2. The pods run, but traffic stops.
set -euo pipefail
kubectl patch deploy/web --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/healthz"}]' >/dev/null
echo "Broken. Symptom: pods are Running but the Service has no ready endpoints after the rollout. Why?"
