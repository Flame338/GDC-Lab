#!/usr/bin/env bash
# Break 1. Something about the rollout is wrong.
set -euo pipefail
kubectl set image deploy/web nginx=nginx:1.27-alpne >/dev/null
echo "Broken. Symptom: a new rollout never finishes. Find out why, write it in JOURNAL.md, then run ../reset.sh"
