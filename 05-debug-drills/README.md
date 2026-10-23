# 05 · Debugging drills (PSE-213)

The JD says "triage product or system issues… across hardware, network, or service operations". These drills build the habit an interviewer wants to hear: compare, narrow, prove.

## Drill A: node-vs-node diff

1. `./nodediff.sh` on a healthy cluster. Note what differs even when nothing is wrong (that's your noise floor).
2. Have someone (or future you, from a shell history you don't look at) run one of these, then find it with `nodediff.sh` alone:
   - `docker exec gdc-lab-worker2 ip link set eth0 mtu 1280`
   - `docker exec gdc-lab-worker2 sysctl -w net.ipv4.ip_forward=0`
   - `docker exec gdc-lab-worker2 sh -c 'echo nameserver 192.0.2.1 > /etc/resolv.conf'`
3. For each one, before fixing it, predict which workloads break and which keep working. Then test your prediction with pods pinned to that node (`nodeName:` or `kubectl run ... --overrides`).

## Drill B: MTU, predict then observe

On a node with a lowered MTU, compare a small request (`wget -qO- http://web`) with a large one (serve a 1 MB file). Write down what you expected, what happened, and why. Overlay networks and tunnels shrink the usable MTU, which is why "small requests work, big ones hang" is the classic symptom.

## Drill C: your own outage, retold

Your Home Assistant boot failure (BSNL primary DNS returning SERVFAIL, router not failing over) is a real triage story. Write it in the table in `../06-stories/failure-table.md` with timings.

## How to talk through any of these (2 minutes)

Symptom → blast radius (one node? all?) → the comparison you ran → the one piece of evidence → root cause → fix → what would have caught it earlier.

Restore everything with `../02-kind/reset.sh`, or `kind delete cluster --name gdc-lab && ../02-kind/up.sh` if a node is beyond saving.
