# Backup and Recovery Plan
**Name:** Althea Barbato

---

## What gets backed up

The backup script at `/usr/local/bin/backup.sh` runs nightly at 2am. It captures:

- nginx config (/etc/nginx/)
- SSL cert and key (/etc/nginx/ssl/)
- Prometheus config (/etc/prometheus/)
- Grafana config (/etc/grafana/)
- Auditd rules (/etc/audit/rules.d/)
- Fail2ban config (/etc/fail2ban/)
- SSH server config (/etc/ssh/sshd_config)

Each backup goes into a timestamped directory under `/var/backups/webserver01/` with individual `.tar.gz` archives per service. A `latest` symlink always points at the most recent one.

---

## Retention

Anything older than 7 days gets automatically deleted by the backup script. One week of daily snapshots is enough for this setup without eating up disk space.

---

## Running a backup manually

```bash
sudo /usr/local/bin/backup.sh
```

To see what it created:
```bash
sudo ls -lh /var/backups/webserver01/latest/
```

---

## Restoring

The restore script at `/usr/local/bin/restore.sh` handles everything. It stops services, puts files back where they belong, and restarts.

From latest:
```bash
sudo /usr/local/bin/restore.sh
```

From a specific backup:
```bash
sudo /usr/local/bin/restore.sh /var/backups/webserver01/20260709-184004
```

---

## Restore test I ran

To test that restore actually works, I ran the backup, then broke nginx on purpose by moving the config file, then restored it.

```bash
sudo /usr/local/bin/backup.sh
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo /usr/local/bin/restore.sh
curl -sk -o /dev/null -w "%{http_code}" https://163.192.117.50
```

Got 200 back after the restore. Cleaned up the .bak file after confirming it worked.

Restore took about 2 minutes. Full Ansible redeploy from scratch takes closer to 5-10 minutes if something is really broken.

---

## What is NOT backed up

- Docker images (they just pull fresh from Docker Hub on redeploy)
- Prometheus historical metrics data (starts collecting fresh after restore)
- Grafana dashboards (provisioned as code in the Ansible role, not stored in the container)
- The OS itself (would need a full disk snapshot for that)
