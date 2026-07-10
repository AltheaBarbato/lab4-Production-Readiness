# Incident Response Summary
**Name:** Althea Barbato

Runbooks for the most likely things to go wrong on webserver01.


## Scenario 1: nginx is down

**Signs:** Uptime Kuma shows HTTP/HTTPS down, site unreachable in browser.

1. SSH in and check nginx status: `sudo systemctl status nginx`
2. Check recent logs: `sudo journalctl -u nginx --since "10 minutes ago"`
3. Restart it: `sudo systemctl restart nginx`
4. If config is broken, find out where: `sudo nginx -t`
5. If disk is full: `df -h` then clear old logs from /var/log

**Recovery check:** `curl -sk https://163.192.117.50` returns 200


## Scenario 2: Unauthorized SSH access

**Signs:** auth.log shows a login from an unfamiliar IP, or Prometheus SSH failed login alert fires.

1. See who's currently logged in: `who` and `last`
2. Kill their session if still active: `sudo pkill -u <username>`
3. Find where they came from: `sudo grep "Accepted" /var/log/auth.log | tail -20`
4. Block the IP: `sudo ufw deny from <ip>`
5. Rotate SSH key right away (generate new, add to authorized_keys, delete old)
6. Check what they did with auditd: `sudo ausearch -ts recent -k identity`
7. Check /etc/passwd and sudoers for anything new

**Recovery check:** new key works, old IP blocked

## Scenario 3: Server compromised, need to restore

**Signs:** files changed, unknown processes, auditd showing writes to sensitive files.

1. Grab logs before touching anything: `sudo tar czf /tmp/forensic-$(date +%s).tar.gz /var/log`
2. Stop services: `sudo systemctl stop nginx docker`
3. Restore from backup: `sudo /usr/local/bin/restore.sh`
4. Rotate all credentials (SSH key, Grafana password)
5. Run verify: `bash scripts/verify.sh`

**Recovery check:** verify.sh passes, everything back up

## Scenario 4: Disk filling up

**Signs:** Prometheus DiskSpaceRunningLow alert fires, or df -h shows over 85%.

1. Find what's eating space: `sudo du -sh /var/log/* | sort -hr | head -10`
2. Force log rotation if needed: `sudo logrotate -f /etc/logrotate.conf`
3. Old backups should auto-delete after 7 days, but can clean manually:
   `find /var/backups/webserver01 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;`
4. Clear unused Docker stuff: `sudo docker system prune -f`

**Recovery check:** df -h under 80%

## Scenario 5: Monitoring stack down

**Signs:** Grafana at :3000 unreachable, Prometheus at :9090 not responding.

1. Check container status: `sudo docker ps -a`
2. Look at logs for whatever exited: `sudo docker logs prometheus`
3. Restart it: `sudo docker start prometheus`
4. Check for port conflicts: `sudo ss -tlnp | grep 9090`
5. If nothing works, redeploy: `bash deploy.sh`

**Recovery check:** `curl -s http://163.192.117.50:9090/-/ready` returns OK


## What monitoring is watching

From Lab 3, Prometheus alerts on:
- Any scrape target going down
- CPU over 80% for 1 minute
- Disk over 85% for 2 minutes
- Memory over 90% for 2 minutes
- Failed SSH logins over 20 total

Uptime Kuma checks HTTP, HTTPS, and Prometheus every 60 seconds.
