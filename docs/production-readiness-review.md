# Production Readiness Review
**Name:** Althea Barbato

Honest look at where webserver01 stands and what would need to happen to call it actually production-ready.

---

## What's working well

**Security hardening is solid for a class project.** SSH is locked down (key-only, no root, low auth tries), UFW is active, fail2ban is watching for brute force, auditd is logging changes to sensitive files, and unnecessary services are gone. Not bad.

**TLS is deployed.** HTTP redirects to HTTPS, TLS 1.2/1.3 only, HSTS header would be a next step but the core encryption is there. Self-signed cert is a limitation but it's the right call without a domain.

**Automated backups are running.** Nightly backup with 7 day retention is better than nothing. Restore was tested and works. That's the minimum bar.

**Monitoring is already there from Lab 3.** Prometheus, Grafana, and Uptime Kuma are all up. Five alert rules covering the main failure modes. Three dashboards. That's more than a lot of small projects have.

**Everything is automated.** ansible deploy.sh is idempotent, verify.sh catches regressions. Someone new could pick this up and run it without reading through a wall of manual steps.

---

## What would need to change for real production

**No domain name.** Self-signed certs mean browser warnings for anyone visiting. Real production needs a real domain and Let's Encrypt. Without it, HTTPS is encrypted but not trusted.

**No backup off-server.** All backups are on the same disk. If the server gets destroyed or the disk fails, the backups are gone too. Real production needs backups going somewhere else, S3 bucket minimum.

**Prometheus has no auth.** /metrics is open to the world. Grafana at least requires login. Prometheus needs a reverse proxy with basic auth or IP allowlisting to be production-safe.

**Single server.** Everything is on one box. Nginx down means the app is down. Real production needs at minimum a load balancer, ideally two servers. Oracle Cloud free tier gives you two instances, could be done.

**No log aggregation.** Logs live on the server. If the server dies, recent logs are gone. Something like Loki or even just remote syslog would fix this.

**Grafana data loss on redeploy.** Dashboard configuration is provisioned as code so that's fine, but historical metrics data is in the Prometheus container. Volume mount is there but a container restart loses the data if the volume isn't persisted to disk outside the container. Would need to check.

---

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
| Disaster recovery | partial (tested restore, but no off-server backup) |
| Log management | basic (no aggregation or shipping) |
| High availability | not there (single server) |
| Auto-scaling | not there (out of scope, free tier) |

For a class project this is pretty strong. For actual production it would need the domain, off-server backups, and Prometheus auth at minimum before I'd feel okay putting real traffic on it.
