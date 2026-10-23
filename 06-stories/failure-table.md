# Failure tables (PSE-214)

Turn Equifax incidents into infra-style answers. One table per incident; each should be tellable in 2 minutes.

## Incident: audit-log sequence reset after the Spring Boot upgrade

| | |
|---|---|
| Detection | How was it noticed? Who noticed, and how long after the deploy? |
| Behaviour | What did users or downstream services see? Duplicate-ID errors where? |
| Blast radius | Which environments, services, tables? |
| Diagnosis | The first hypothesis, what ruled it out, the evidence that proved the cause |
| Root cause | |
| Fix | What changed, and how you verified it before UAT |
| Prevention | The check or test that would catch it next time |
| Air-gap angle | If this shipped to a site you can't reach for weeks, what would have had to be true (preflight check, rollback path, support bundle)? |

## Incident: (second one, e.g. the vulnerability remediation or a production issue)

| | |
|---|---|
| Detection | |
| Behaviour | |
| Blast radius | |
| Diagnosis | |
| Root cause | |
| Fix | |
| Prevention | |
| Air-gap angle | |

## Incident: Home Assistant would not start after a power cycle (personal)

| | |
|---|---|
| Detection | App and web UI unreachable after restart; console showed Supervisor up, Core not started |
| Behaviour | Supervisor refused to start Core ("not ready"); intermittent errors reaching ghcr.io |
| Diagnosis | Checked clock, DNS, network; probed each resolver separately |
| Root cause | ISP's primary DNS returned SERVFAIL for ghcr.io; router forwarded only to it |
| Fix | Router upstream DNS set to public resolvers |
| Prevention | (fill in: monitoring, a second resolver, a boot-time check) |
| Air-gap angle | (fill in: why "pull the image at boot" can never be the design in an air-gapped site) |

## The two short answers to have ready

- **"How do you use AI in your work?"** (30 s): 
- **"Why is air-gapped different?"** (1 sentence): 
