# gdc-lab

Hands-on prep for the Google Distributed Cloud (air-gapped) SWE II loop, VM team. Each folder is one Linear ticket. They are exercises, not solutions: failing tests, broken clusters and blank tables that you fill in, so the stories you tell in the interview are things you actually did.

| Folder | Ticket | Due | What you end up able to say |
|---|---|---|---|
| `01-workerpool` | PSE-210 | 25 Oct | "I can write a bounded, cancellable worker pool in Go and explain every channel." |
| `02-kind` | PSE-211 | 28 Oct | "I broke a cluster six ways and debugged each with describe, events and logs." |
| `03-controller` | PSE-217 | 1 Nov | "I built a controller with a finalizer and made reconcile idempotent." |
| `04-kubevirt` | PSE-212 | 3 Nov | "I booted a VM on Kubernetes and can explain VM vs VMI vs virt-launcher." |
| `05-debug-drills` | PSE-213 | 4 Nov | "My first move is a node-vs-node diff, and here's one I found that way." |
| `06-stories` | PSE-214 | 5 Nov | Two-minute failure tables for real incidents, with an air-gap angle. |

Cut order if time runs short (from the Linear project): GCP lab first, then `04-kubevirt`, then `05-debug-drills`. Protect `03-controller`, `06-stories` and the mock round (PSE-216).

## Setup (Windows: do all of this inside WSL)

- Go 1.22+ · Docker Desktop with WSL integration · [kind](https://kind.sigs.k8s.io/) · kubectl · [kubebuilder](https://book.kubebuilder.io/quick-start) for 03

## 01 · Worker pool

```bash
go test ./01-workerpool/...          # fails until you implement Run
go test -race ./01-workerpool/...    # the real bar
```

Read the requirements in `workerpool.go`. Give it 25 minutes before you look at the hints in the comment, the same rule you use for LeetCode.

## 02 · Break kind on purpose

```bash
./02-kind/up.sh                      # cluster + healthy baseline app
./02-kind/break/01-image.sh          # break it (don't read the script first)
# ... debug with kubectl get/describe/logs/events, fill in 02-kind/JOURNAL.md
./02-kind/reset.sh                   # restore, then the next break
```

## Ground rules

- Narrate as you go, out loud, like the interviewer is watching.
- Every exercise ends with one line in the Loop Gym "Close the day" card: what tripped you up.
- Commit your attempts. Your commit history is the evidence for the weekly report card.
