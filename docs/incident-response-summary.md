# Incident Response Summary
**Name:** Althea Barbato

Runbooks for the most likely things to go wrong on webserver01.

---

## Scenario 1: Web server down (nginx not responding)

**Signs:** Uptime Kuma shows HTTP/HTTPS down, can't reach the site in a browser.

**Steps:**
1. SSH in: `ssh -i ~/.ssh/lab1-key.pem sysadmin@163.192.117.50`
2. Check nginx: `sudo systemctl status nginx`
3. If it crashed, check logs: `sudo journalctl -u nginx --since "10 minutes ago"`
4. Try restarting: `sudo systemctl restart nginx`
5. If config is broken: `sudo nginx -t` to find the problem
6. If disk is full: `df -h` and clear old logs in /var/log

**Recovery check:** `curl -sk https://163.192.117.50` should return 200

---

## Scenario 2: Someone gets into SSH (unauthorized access)

**Signs:** auth.log shows a login from an unfamiliar IP, Prometheus alert on failed logins spikes.

**Steps:**
1. Check who's logged in right now: `who` and `last`
2. Kill active session if needed: `sudo pkill -u <username>`
3. Check auth.log for the source IP: `sudo grep "Accepted" /var/log/auth.log | tail -20`
4. Block the IP in UFW: `sudo ufw deny from <ip>`
5. Rotate my SSH key immediately (generate new, add to authorized_keys, remove old)
6. Check auditd for what they did: `sudo ausearch -ts recent -k identity`
7. Review /etc/passwd and sudoers for any new accounts or changes

**Recovery check:** new key works, old source IP blocked in UFW

---

## Scenario 3: Server is compromised, need to restore from backup

**Signs:** files modified, unknown processes running, audit log shows changes to sensitive files.

**Steps:**
1. Take a snapshot of current state for forensics: `sudo tar czf /tmp/forensic-$(date +%s).tar.gz /var/log`
2. Stop services to prevent further damage: `sudo systemctl stop nginx docker`
3. Run the restore script: `sudo /usr/local/bin/restore.sh` (restores from latest backup)
   - Or from a specific backup: `sudo /usr/local/bin/restore.sh /var/backups/webserver01/backup-YYYYMMDD-HHMMSS`
4. Rotate all credentials (SSH keys, Grafana password)
5. Verify restore worked: `bash scripts/verify.sh`

**Recovery check:** verify.sh passes, services back up

---

## Scenario 4: Disk filling up

**Signs:** Prometheus DiskSpaceRunningLow alert fires, df -h shows >85% used.

**Steps:**
1. Find what's using space: `sudo du -sh /var/log/* | sort -hr | head -10`
2. Rotate logs if needed: `sudo logrotate -f /etc/logrotate.conf`
3. Check backup directory: `ls -lh /var/backups/webserver01/`
4. Old backups should auto-delete after 7 days, but manually clean if needed:
   `find /var/backups/webserver01 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;`
5. Clear old Docker images if any: `sudo docker system prune -f`

**Recovery check:** df -h shows <80% used

---

## Scenario 5: Monitoring stack down (Prometheus/Grafana)

**Signs:** Can't access Grafana at :3000, Prometheus at :9090 is unreachable.

**Steps:**
1. Check Docker containers: `sudo docker ps -a`
2. If a container exited, check why: `sudo docker logs prometheus` (or grafana/uptime-kuma/node-exporter)
3. Restart the container: `sudo docker start prometheus`
4. If it keeps crashing, check if port is conflicting: `sudo ss -tlnp | grep 9090`
5. If totally broken, redeploy: `bash deploy.sh`

**Recovery check:** `curl -s http://163.192.117.50:9090/-/ready` returns OK

---

## What monitoring covers

Prometheus + Grafana from Lab 3 handles alerting for:
- Instance down (any scrape target missing)
- CPU over 80% for 1 minute
- Disk over 85% for 2 minutes
- Memory over 90% for 2 minutes
- Failed SSH logins over 20 total

Uptime Kuma watches HTTP, HTTPS, and Prometheus availability with 60 second intervals.
