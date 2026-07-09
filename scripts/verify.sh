#!/bin/bash
SERVER_IP="163.192.117.50"
SSH_KEY="$HOME/.ssh/lab1-key.pem"
SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o ConnectTimeout=10"
PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"
    if [[ "$result" == "ok" ]]; then
        echo "  [PASS] $label"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $label ($result)"
        FAIL=$((FAIL + 1))
    fi
}

echo "--- SSH Hardening ---"
root=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "grep '^PermitRootLogin' /etc/ssh/sshd_config | awk '{print \$2}'")
check "PermitRootLogin no" "$( [[ "$root" == "no" ]] && echo ok || echo "got $root" )"

pwauth=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "grep '^PasswordAuthentication' /etc/ssh/sshd_config | awk '{print \$2}'")
check "PasswordAuthentication no" "$( [[ "$pwauth" == "no" ]] && echo ok || echo "got $pwauth" )"

echo "--- TLS ---"
tls=$(curl -sk -o /dev/null -w "%{http_code}" "https://$SERVER_IP" --insecure)
check "HTTPS reachable" "$( [[ "$tls" == "200" ]] && echo ok || echo "got $tls" )"

redirect=$(curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_IP")
check "HTTP redirects to HTTPS" "$( [[ "$redirect" == "301" ]] && echo ok || echo "got $redirect" )"

cert=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "test -f /etc/nginx/ssl/server.crt && echo ok || echo missing")
check "TLS cert present" "$cert"

echo "--- Fail2ban ---"
f2b=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo systemctl is-active fail2ban")
check "fail2ban running" "$( [[ "$f2b" == "active" ]] && echo ok || echo "$f2b" )"

echo "--- Auditd ---"
auditd=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo systemctl is-active auditd")
check "auditd running" "$( [[ "$auditd" == "active" ]] && echo ok || echo "$auditd" )"

echo "--- Firewall ---"
ufw=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo ufw status | head -1 | awk '{print \$2}'")
check "UFW active" "$( [[ "$ufw" == "active" ]] && echo ok || echo "not active" )"

echo "--- Backup ---"
backup=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "test -d /var/backups/webserver01/latest && echo ok || echo missing")
check "backup exists" "$backup"

backup_files=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "ls /var/backups/webserver01/latest/*.tar.gz 2>/dev/null | wc -l")
check "backup has files ($backup_files)" "$( [[ "$backup_files" -ge 3 ]] && echo ok || echo "only $backup_files files" )"

echo "--- Kernel Hardening ---"
syncookies=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sysctl -n net.ipv4.tcp_syncookies")
check "tcp_syncookies on" "$( [[ "$syncookies" == "1" ]] && echo ok || echo "got $syncookies" )"

echo ""
echo "done $PASS passed, $FAIL failed"
