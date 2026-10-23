# 03 · Toy controller: `Guest` (PSE-217)

A tiny stand-in for what a VM team's controller does: a custom resource says "this guest should be running", and the controller makes the cluster match. You write the controller; `checks.sh` tells you when it behaves.

## The resource

```yaml
apiVersion: lab.gdc.dev/v1alpha1
kind: Guest
spec:
  image: busybox:1.36   # what to run
  running: true         # desired power state
status:
  phase: Pending | Running | Stopped
  podName: guest-a-vm
```

## Required behaviour

1. `running: true` → exactly one Pod named `<guest>-vm`, labelled `lab.gdc.dev/guest=<guest>`, owned by the Guest (ownerReference), running `sleep 3600` in `spec.image`.
2. `running: false` → no Pod. `status.phase = Stopped`.
3. On first reconcile, add the finalizer `lab.gdc.dev/cleanup` and create a ConfigMap `<guest>-ip` with a fake IP (`10.99.0.<n>`). It plays the part of an external resource (an IP lease), so it has **no** ownerReference: garbage collection must not be what removes it.
4. On delete: remove the ConfigMap, then remove the finalizer. Nothing else.
5. Reconcile is idempotent and level-triggered. Re-running it on unchanged state changes nothing; a Pod deleted by someone else comes back.
6. `status.phase` mirrors reality (Running only when the Pod is Running).

## Steps

```bash
# needs Go, Docker, kind (02-kind/up.sh), and kubebuilder (https://book.kubebuilder.io/quick-start)
mkdir guest-controller && cd guest-controller
kubebuilder init --domain gdc.dev --repo github.com/Flame338/gdc-lab/guest-controller
kubebuilder create api --group lab --version v1alpha1 --kind Guest   # yes to resource and controller
# 1. edit api/v1alpha1/guest_types.go (spec + status, add +kubebuilder:subresource:status)
# 2. make manifests && make install
# 3. write Reconcile in internal/controller/guest_controller.go
#    and add Owns(&corev1.Pod{}) in SetupWithManager
# 4. make run            # controller runs on your machine against kind
# 5. ../checks.sh        # in another terminal
```

## Questions to answer out loud when it passes

- Why is it fine for Reconcile to be called many times for one change?
- What happens if the controller crashes between creating the Pod and writing status?
- Stop `make run`, then `kubectl delete guest guest-a`. What do you see, and why is that the right behaviour?
- How would you report progress for a slow operation like a VM disk import?

**Cut line:** if short on time, skip status (behaviour 6). Keep the finalizer and idempotency.
