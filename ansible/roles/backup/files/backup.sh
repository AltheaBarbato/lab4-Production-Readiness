#!/bin/bash
set -e

BACKUP_DIR="/var/backups/webserver01"
DATE=$(date +%Y%m%d-%H%M%S)
DEST="$BACKUP_DIR/$DATE"

mkdir -p "$DEST"

# nginx config and web content
tar -czf "$DEST/nginx.tar.gz" /etc/nginx /var/www/html 2>/dev/null

# SSL certs
tar -czf "$DEST/ssl.tar.gz" /etc/nginx/ssl 2>/dev/null

# monitoring configs
tar -czf "$DEST/prometheus.tar.gz" /etc/prometheus 2>/dev/null
tar -czf "$DEST/grafana.tar.gz" /etc/grafana 2>/dev/null

# system configs
tar -czf "$DEST/etc-configs.tar.gz" \
  /etc/ssh/sshd_config \
  /etc/fail2ban/jail.local \
  /etc/audit/rules.d \
  /etc/apt/apt.conf.d/20auto-upgrades \
  2>/dev/null

# update latest symlink
ln -sfn "$DEST" "$BACKUP_DIR/latest"

# remove backups older than 7 days
find "$BACKUP_DIR" -maxdepth 1 -mindepth 1 -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null || true

echo "backup completed: $DEST"
