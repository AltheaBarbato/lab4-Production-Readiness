#!/bin/bash
# restore from a backup - usage: restore.sh [backup-dir]
# defaults to latest if no arg given

BACKUP_DIR="/var/backups/webserver01"
SOURCE="${1:-$BACKUP_DIR/latest}"

if [[ ! -d "$SOURCE" ]]; then
    echo "backup not found: $SOURCE"
    exit 1
fi

echo "restoring from $SOURCE"

# stop services before restore
systemctl stop nginx
docker stop prometheus grafana nginx_exporter node_exporter 2>/dev/null || true

# restore nginx
tar -xzf "$SOURCE/nginx.tar.gz" -C / 2>/dev/null && echo "nginx config restored"

# restore ssl
tar -xzf "$SOURCE/ssl.tar.gz" -C / 2>/dev/null && echo "ssl certs restored"

# restore prometheus config
tar -xzf "$SOURCE/prometheus.tar.gz" -C / 2>/dev/null && echo "prometheus config restored"

# restore grafana config
tar -xzf "$SOURCE/grafana.tar.gz" -C / 2>/dev/null && echo "grafana config restored"

# restore system configs
tar -xzf "$SOURCE/etc-configs.tar.gz" -C / 2>/dev/null && echo "system configs restored"

# restart everything
systemctl start nginx
docker start node_exporter prometheus grafana nginx_exporter 2>/dev/null || true

echo "restore complete - verify services are running"
