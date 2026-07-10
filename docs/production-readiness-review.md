# Production Readiness Review
**Name:** Althea Barbato

Honest look at where webserver01 stands and what would need to change to call it actually production ready.

## What's working

Security hardening is solid for a class project. SSH is key-only with no root login allowed, fail2ban blocks brute force, auditd watches the four most sensitive files, and services that had no reason to be there are gone.

TLS is deployed. HTTP redirects to HTTPS, TLS 1.2/1.3 only. Self-signed cert means browser warnings but the encryption is real. It's the right call without a domain name.

Backups are running nightly and the restore was tested and works. 7 day retention keeps disk usage reasonable.

Monitoring from Lab 3 is still up. Prometheus, Grafana, and Uptime Kuma are all running with five alert rules and three dashboards covering the main failure modes.

Everything is automated with Ansible. deploy.sh is idempotent and verify.sh catches regressions. Someone else could pick this up and run it without needing to read through a bunch of manual steps.

## What would need to change for real production

No domain name. Self signed certs trigger browser security warnings for anyone who visits. Real production needs a domain and Let's Encrypt. Without that, HTTPS is encrypted but not trusted by browsers.

No off server backups. Everything is on the same disk. If the server dies, the backups die with it. A real setup needs backups going somewhere else, at minimum an S3 bucket.

Prometheus has no auth. The /metrics endpoint is open to anyone who knows the IP and port. Grafana at least requires login. Prometheus would need a reverse proxy with basic auth or IP allowlisting before this was safe for real traffic.

Single server. If nginx crashes or the instance goes down, everything is down. Real production would want at least a load balancer and a second server. Oracle Cloud free tier actually gives two instances so it's doable.

No log aggregation. Logs are on the server. If the server dies, recent logs are gone. Remote syslog or something like Loki would fix this.

## Production readiness score

| Area | Status |
|---|---|
| TLS/HTTPS | partial (self-signed, works but browser warnings) |
| Authentication | partial (Grafana yes, Prometheus no) |
| Firewalling | good |
| SSH hardening | good |
| Monitoring | good |
| Alerting | good |
| Automated backups | partial (on-server only) |
| Disaster recovery | partial (tested restore, no off-server copy) |
| Log management | basic (no aggregation) |
| High availability | not there (single server) |
| Auto-scaling | not there (free tier, out of scope) |

For a class project this is genuinely pretty good. For real production it would need the domain, off-server backups, and Prometheus auth at minimum before I'd put actual traffic on it.
