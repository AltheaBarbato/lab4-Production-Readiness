# Hardening Checklist
**Name:** Althea Barbato

What's done and what's not on webserver01.

| Control | Status | How |
|---|---|---|
| TLS certificate deployed | done | self-signed, /etc/nginx/ssl/ |
| HTTP redirects to HTTPS | done | nginx 301 redirect |
| TLS 1.2 and 1.3 only | done | nginx ssl_protocols |
| Root SSH login disabled | done | sshd_config |
| Password auth disabled | done | sshd_config |
| SSH MaxAuthTries 3 | done | sshd_config |
| SSH idle timeout 5 min | done | ClientAliveInterval 300 |
| X11 forwarding off | done | sshd_config |
| Agent forwarding off | done | sshd_config |
| UFW firewall active | done | from Lab 1 |
| Only needed ports open | done | 22/80/443/9090/3000/3001/9100/9113 |
| Fail2ban running | done | jail.local configured |
| Fail2ban ban time 1 hour | done | bantime=3600 |
| Auditd running | done | watching passwd/shadow/sudoers/sshd_config |
| Unnecessary services removed | done | telnet/rsh/talk/finger gone, cups/avahi disabled |
| Least privilege - /tmp locked | done | noexec/nosuid/nodev mount |
| Least privilege - SUID audit | done | scanned for unexpected SUID binaries |
| SYN cookie protection | done | sysctl tcp_syncookies=1 |
| ICMP redirects blocked | done | sysctl accept_redirects=0 |
| Reverse path filtering | done | sysctl rp_filter=1 |
| dmesg restricted | done | sysctl kernel.dmesg_restrict=1 |
| Auto security updates | done | unattended-upgrades |
| Automated backups | done | nightly cron, 7 day retention |
| Restore script | done | /usr/local/bin/restore.sh |
| Monitoring and alerting | done | Prometheus + Grafana from Lab 3 |

## Known gaps

| Control | Why not done |
|---|---|
| Let's Encrypt cert | Needs a domain name, server only has an IP |
| Prometheus auth | No built-in auth, would need reverse proxy |
| Off-server log shipping | Out of scope, would need remote syslog |
| DDoS protection | Free tier, no CDN budget |
| CIS full compliance | Way out of scope for a class project |
