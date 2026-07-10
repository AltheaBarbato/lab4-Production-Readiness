# Backup and Recovery Plan
**Name:** Althea Barbato

## What's backed up

The backup script at `/usr/local/bin/backup.sh` runs nightly at 2am and captures:

- nginx configuration (/etc/nginx/)
- SSL certificate and key (/etc/nginx/ssl/)
- Prometheus config (/etc/prometheus/)
- Grafana config (/etc/grafana/)
- Auditd rules (/etc/audit/rules.d/)
- Fail2ban config (/etc/fail2ban/)
- SSH server config (/etc/ssh/sshd_config)

Each backup is a timestamped directory under `/var/backups/webserver01/` with individual `.tar.gz` archives per service. A `latest` symlink always points to the most recent backup.

## Retention

Backups older than 7 days are automatically deleted by the backup script. That gives one week of daily snapshots without filling the disk.

## How to run a manual backup

```bash
sudo /usr/local/bin/backup.sh
```

Check what was created:
```bash
ls -lh /var/backups/webserver01/latest/
```

---

## How to restore

The restore script at `/usr/local/bin/restore.sh` handles the full restore process.

**Restore from latest backup:**
```bash
sudo /usr/local/bin/restore.sh
```

**Restore from a specific backup:**
```bash
sudo /usr/local/bin/restore.sh /var/backups/webserver01/backup-20260101-020000
```

The script stops services, restores files to their original locations, then restarts everything.

## Demo: run a backup and then restore it

This is what I ran to test the backup/restore cycle:

**Step 1: run the backup**
```bash
sudo /usr/local/bin/backup.sh
```

Output should show each archive being created, then print the backup directory path.

**Step 2: verify backup contents**
```bash
ls -lh /var/backups/webserver01/latest/
```
Should show at least: nginx.tar.gz, ssl.tar.gz, prometheus.tar.gz, grafana.tar.gz, system-security.tar.gz

**Step 3: simulate a config change (break something)**
```bash
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
```

**Step 4: restore**
```bash
sudo /usr/local/bin/restore.sh
```

**Step 5: verify nginx is working again**
```bash
curl -sk -o /dev/null -w "%{http_code}" https://163.192.117.50
```
Should return 200.

**Step 6: clean up the bak file**
```bash
sudo rm -f /etc/nginx/nginx.conf.bak
```


## Recovery time estimate

Restore from backup takes about 2-3 minutes. Biggest issue is restarting Docker containers. Full redeploy from Ansible if something is really broken takes 5-10 minutes.

---

## What's NOT backed up

- Docker images (they pull fresh from Docker Hub on redeploy)
- Prometheus metrics data (historical data lost, starts collecting fresh)
- Grafana dashboards (those are provisioned as code in the Ansible role)
- The OS itself (would need a full disk snapshot for that, out of scope)
