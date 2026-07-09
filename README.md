# Lab 4: Production Readiness, Security Hardening & Resilience
**Name:** Althea Barbato

Building on Labs 1-3 to get webserver01 closer to production-ready. Covers TLS deployment, backup/recovery, and deeper security hardening, all automated with Ansible.

**Server:** webserver01 (163.192.117.50, Oracle Cloud free tier)

---

## What this does

- **TLS certificate** - self-signed cert deployed to nginx, HTTP redirects to HTTPS, TLS 1.2/1.3 only
- **Security hardening** - removes unnecessary packages and services, tightens SSH, enables auditd, configures fail2ban, locks /tmp, sysctl hardening
- **Automated backups** - nightly cron backup of all configs, 7 day retention, tested restore script

---

## Files

```
ansible/
  inventory.ini           - server connection info
  vars/main.yml           - shared variables
  site.yml                - main playbook (imports the three below)
  playbooks/
    01-hardening.yml
    02-tls.yml
    03-backup.yml
  roles/
    hardening/            - security hardening role
    tls/                  - nginx TLS config role
    backup/               - backup scripts and cron role

scripts/
  verify.sh               - 11 checks to confirm everything deployed correctly

docs/
  vulnerability-report.md     - findings from manual assessment
  threat-model.md             - STRIDE analysis
  hardening-checklist.md      - what was done and what wasn't
  incident-response-summary.md - runbooks for common failure scenarios
  backup-recovery-plan.md     - how backup/restore works
  production-readiness-review - honest assessment of gaps
```

---

## How to deploy

From WSL:
```bash
bash deploy.sh
```

Second run should be idempotent (changed=0).

---

## How to verify

```bash
bash scripts/verify.sh
```

Checks: SSH hardening, HTTPS up, HTTP redirect, TLS cert present, fail2ban, auditd, UFW, backup exists, backup has files, tcp_syncookies.

---

## Screenshots to turn in

1. `bash deploy.sh` output (first run)
2. `bash scripts/verify.sh` output (all passing)
3. `curl -Ik https://163.192.117.50` showing TLS cert info
4. Grafana and Uptime Kuma still up from Lab 3

---

## Prerequisites

- Oracle Cloud VCN Security List must have port 443 open (TCP ingress)
- SSH key at `~/.ssh/lab1-key.pem`
- Ansible installed in WSL
- Python 3.9 bootstrap handled by the first play in site.yml
