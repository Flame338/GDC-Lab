# 04 · KubeVirt on kind: boot a VM and read its lifecycle (PSE-212)

The GDC VM team builds VMs on top of Kubernetes. KubeVirt is the closest open-source thing you can run at home. The goal is not the install; it is being able to explain what each object is for.

## Install (on the kind cluster from 02-kind)

```bash
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml
# kind nodes usually have no /dev/kvm, so use software emulation (slow, fine for learning):
kubectl -n kubevirt patch kubevirt kubevirt --type=merge \
  -p '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
kubectl -n kubevirt wait kv kubevirt --for condition=Available --timeout=10m
```

Get `virtctl` from the same release page (it matches `$VERSION`). On Windows, run all of this inside WSL with Docker Desktop's WSL integration on.

Check the current KubeVirt docs if any command above has changed; this was written in Oct 2026.

## Walk the lifecycle and write down what you see

```bash
kubectl apply -f vm.yaml
kubectl get vm,vmi,pods          # 1. VM exists. VMI? Pod?
virtctl start testvm
kubectl get vm,vmi,pods -w       # 2. which objects appear, in what order?
kubectl describe vmi testvm      # 3. phase transitions, which node
kubectl get pod -l kubevirt.io=virt-launcher -o wide
virtctl console testvm           # 4. log in (cirros / gocubsgo), Ctrl+] to leave
virtctl stop testvm              # 5. what disappears, what stays?
kubectl delete vm testvm
```

## Answer these in your own words (interview material)

1. What is the difference between a `VirtualMachine` and a `VirtualMachineInstance`? Why have both?
2. What runs inside the `virt-launcher` pod, and why is a VM a pod at all?
3. What do `virt-controller`, `virt-handler` and `virt-api` each do? Which one runs on every node?
4. What would live migration need to move, and what can't it move with a `containerDisk`?
5. In an air-gapped site, where does `quay.io/kubevirt/cirros-container-disk-demo` come from? What has to be mirrored before any of this works?

**Cut line:** if emulation is too slow on your laptop, do steps 1–3 and the questions; skip the console.
