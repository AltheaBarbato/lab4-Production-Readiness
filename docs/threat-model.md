# Threat Model
**Name:** Althea Barbato

STRIDE breakdown for webserver01.

## What I'm protecting

- The server (Ubuntu 20.04, Oracle Cloud free tier)
- nginx serving the web app over HTTPS (ports 80/443)
- Monitoring stack from Lab 3 (Prometheus, Grafana, Uptime Kuma)
- SSH access
- Backups in /var/backups/webserver01
- Logs and audit records

## Who would attack this

**Automated scanners** most likely. Constant background noise on any internet-facing server, looking for open ports and default creds.

**Credential stuffers** try password combos from other breaches. Not relevant since password auth is off.

**Targeted attacker** someone actually after this server. Unlikely, it's a class project.

## STRIDE

### Spoofing
Pretending to be a legitimate user to get SSH access or impersonating the server to intercept traffic.

Key only auth handles the SSH side. TLS cert on nginx means clients can verify they're talking to the right server (self-signed means they'll get a browser warning but the encryption still works).

Risk left: private key on my laptop, if that gets compromised someone has access.

### Tampering
Changing files, configs, or data on the server without authorization.

auditd watches the four most sensitive files. UFW and iptables block unauthorized ports. Backups mean even if something gets wiped, it can be recovered.

Risk left: audit logs are on the same server. Root access = logs gone.

### Repudiation
Not being able to tell who did what.

auditd logs user commands with timestamps. Auth events in auth.log. Both feed into monitoring from Lab 3.

Risk left: no off server log shipping.

### Information disclosure
Server info leaking to people who shouldn't see it.

HTTPS now means web traffic is encrypted. Grafana and Uptime Kuma require login. kernel.dmesg_restrict=1 hides kernel info from non-root users.

Risk left: Prometheus /metrics is still wide open with no auth.

### Denial of Service
Overwhelming the server until it's unavailable.

tcp_syncookies=1 handles SYN floods. Fail2ban blocks brute force attempts. HTTP to HTTPS redirect keeps port 80 alive without processing actual requests.

Risk left: volumetric DDoS from many IPs, no CDN in place.

### Elevation of privilege
Getting from regular user to root.

fs.suid_dumpable=0, sudoers is audit-watched, removed unnecessary packages that could provide escalation paths.

Risk left: kernel exploits. Auto-updates help but there's always a window.


## Open ports

| Port | Service | Exposure | Risk |
|---|---|---|---|
| 22 | SSH | 0.0.0.0/0 | Medium (key-only, fail2ban) |
| 80 | nginx (redirect) | 0.0.0.0/0 | Low (just redirects to 443) |
| 443 | nginx HTTPS | 0.0.0.0/0 | Low (TLS, static content) |
| 9090 | Prometheus | 0.0.0.0/0 | Low-Medium (no auth) |
| 3000 | Grafana | 0.0.0.0/0 | Low (login required) |
| 3001 | Uptime Kuma | 0.0.0.0/0 | Low (login required) |
| 9100 | node_exporter | 0.0.0.0/0 | Low (read only) |
| 9113 | nginx_exporter | 0.0.0.0/0 | Low (read only) |
