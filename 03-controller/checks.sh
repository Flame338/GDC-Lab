#!/usr/bin/env bash
# Acceptance checks for the toy Guest controller (PSE-217).
# Run your controller (`make run` in another terminal), then: ./checks.sh
set -uo pipefail
cd "$(dirname "$0")"
G=guest-a; POD=$G-vm; CM=$G-ip; SEL="lab.gdc.dev/guest=$G"
pass=0; fail=0
ok(){ echo "  PASS  $1"; pass=$((pass+1)); }
no(){ echo "  FAIL  $1"; fail=$((fail+1)); }
wait_for(){ # wait_for <seconds> <command...>
  local t=$1; shift; for _ in $(seq "$t"); do "$@" >/dev/null 2>&1 && return 0; sleep 1; done; return 1; }
pods(){ kubectl get pods -l "$SEL" --no-headers 2>/dev/null | grep -v Terminating | wc -l; }
phase(){ kubectl get guest "$G" -o jsonpath='{.status.phase}' 2>/dev/null; }

kubectl delete guest "$G" --ignore-not-found --wait=true >/dev/null 2>&1
echo "1. Create a running Guest"
kubectl apply -f guest-sample.yaml >/dev/null
wait_for 30 kubectl get pod "$POD" && ok "pod $POD created" || no "pod $POD not created within 30s"
wait_for 30 kubectl get configmap "$CM" && ok "configmap $CM (the 'IP allocation') created" || no "configmap $CM not created"
wait_for 60 bash -c "[ \"\$(kubectl get guest $G -o jsonpath='{.status.phase}')\" = Running ]" && ok "status.phase = Running" || no "status.phase is '$(phase)', want Running"
kubectl get guest "$G" -o jsonpath='{.metadata.finalizers}' | grep -q 'lab.gdc.dev/cleanup' && ok "finalizer lab.gdc.dev/cleanup is set" || no "finalizer missing"
kubectl get pod "$POD" -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null | grep -qx Guest && ok "pod is owned by the Guest" || no "pod has no ownerReference to the Guest"

echo "2. Idempotent: re-apply the same spec three times"
for _ in 1 2 3; do kubectl apply -f guest-sample.yaml >/dev/null; kubectl annotate guest "$G" poke="$RANDOM" --overwrite >/dev/null; done
sleep 5
[ "$(pods)" = 1 ] && ok "still exactly one pod" || no "found $(pods) pods, want 1"

echo "3. Level-triggered: delete the pod behind the controller's back"
kubectl delete pod "$POD" --wait=true >/dev/null
wait_for 30 bash -c "[ \"\$(kubectl get pods -l $SEL --no-headers 2>/dev/null | grep -v Terminating | wc -l)\" = 1 ]" && ok "pod recreated" || no "pod not recreated (does your controller watch Pods it owns?)"

echo "4. Stop it"
kubectl patch guest "$G" --type=merge -p '{"spec":{"running":false}}' >/dev/null
wait_for 30 bash -c "[ \"\$(kubectl get pods -l $SEL --no-headers 2>/dev/null | grep -v Terminating | wc -l)\" = 0 ]" && ok "pod removed" || no "pod still there"
wait_for 30 bash -c "[ \"\$(kubectl get guest $G -o jsonpath='{.status.phase}')\" = Stopped ]" && ok "status.phase = Stopped" || no "status.phase is '$(phase)', want Stopped"
kubectl get configmap "$CM" >/dev/null 2>&1 && ok "IP allocation kept while stopped" || no "configmap deleted on stop; it should only go on delete"

echo "5. Delete: the finalizer cleans up, then lets go"
kubectl delete guest "$G" --wait=false >/dev/null
wait_for 30 bash -c "! kubectl get configmap $CM" && ok "configmap released" || no "configmap $CM still exists"
wait_for 30 bash -c "! kubectl get guest $G" && ok "Guest gone" || no "Guest stuck in deletion (finalizer never removed?)"

echo; echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
