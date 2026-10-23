#!/usr/bin/env bash
# Node-vs-node diff for the kind cluster: snapshot what usually differs
# between a healthy node and a broken one, then diff two nodes.
# Usage: ./nodediff.sh gdc-lab-worker gdc-lab-worker2
set -euo pipefail
a=${1:-gdc-lab-worker}; b=${2:-gdc-lab-worker2}
out=$(mktemp -d)
snap(){ docker exec "$1" sh -c '
  echo "## kernel";      uname -r
  echo "## kubelet";     kubelet --version 2>/dev/null
  echo "## runtime";     crictl --version 2>/dev/null
  echo "## links (name mtu state)"; ip -o link | awk "{print \$2, \$4, \$5, \$9}" | sed "s/@[^:]*//" | grep -v "^veth"
  echo "## routes";      ip route | grep -v "dev veth" | sed "s/ proto kernel//"
  echo "## dns";         grep -v "^#" /etc/resolv.conf
  echo "## cni config";  ls /etc/cni/net.d 2>/dev/null; cat /etc/cni/net.d/* 2>/dev/null | grep -i -E "mtu|type|subnet" || true
  echo "## sysctls";     sysctl net.ipv4.ip_forward net.bridge.bridge-nf-call-iptables 2>/dev/null
  echo "## iptables rule count"; iptables-save 2>/dev/null | grep -c "^-A" || true
  echo "## disk";        df -h / | tail -1 | awk "{print \$5\" used\"}"
' | sed "s/$1/<node>/g"; }
snap "$a" > "$out/$a"; snap "$b" > "$out/$b"
if diff -u "$out/$a" "$out/$b"; then echo "No differences in the usual suspects."; fi
