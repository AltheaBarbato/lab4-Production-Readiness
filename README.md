# Lab 4: Production Readiness, Security Hardening & Resilience
**Name:** Althea Barbato

Built on top of Labs 1-3 to get webserver01 closer to production ready. This lab covers TLS deployment, deeper security hardening, and automated backups with a tested restore, all automated through Ansible.

**Server:** webserver01 (163.192.117.50, Oracle Cloud free tier)

## What this does

- **TLS** - self signed cert deployed to nginx, HTTP redirects to HTTPS, TLS 1.2/1.3 only
- **Security hardening** - removed unnecessary packages and services, tightened SSH config, enabled auditd, configured fail2ban, locked /tmp, sysctl kernel hardening
- **Automated backups** - nightly cron at 2am, 7 day retention, restore script tested


## Files

```
ansible/
  inventory.ini           - server connection info
  vars/main.yml           - shared variables
  site.yml                - main playbook, imports the three below
  playbooks/
    01-hardening.yml
    02-tls.yml
    03-backup.yml
  roles/
    hardening/            - security hardening role
    tls/                  - nginx TLS config role
    backup/               - backup scripts and cron role

scripts/
  verify.sh               - 11 checks confirming everything deployed correctly

docs/
  vulnerability-report.md
  threat-model.md
  hardening-checklist.md
  incident-response-summary.md
  backup-recovery-plan.md
  production-readiness-review.md
```


## Deploying

```bash
bash deploy.sh
```

Second run is idempotent (changed=0).

## Verifying

```bash
bash scripts/verify.sh
```

Checks SSH hardening, HTTPS, HTTP redirect, TLS cert, fail2ban, auditd, UFW, backup directory, backup files, and tcp_syncookies. All 11 pass.
