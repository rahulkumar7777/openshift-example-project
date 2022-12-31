#!/usr/bin/sh

STAMP=$(date)

# generate host keys
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  /usr/bin/ssh-keygen -A
fi

# generate memSQL config
if [ ! -f /data/settings.conf ]; then
  cat << EOF > /data/settings.conf
[memsql-ops]
port = 9000
memsql_installs_dir = /memsql
ops_datadir = /data
host = memsql-master.example.svc.cluster.local
started_as_root = False
EOF
fi

echo "[${STAMP}] Starting sshd on port 9022 ..."
/usr/sbin/sshd -p 9022

echo "[${STAMP}] Starting daemon..."
rm /data/data/memsql-ops.pid
sed -i '/user = memsql/d' /data/settings.conf

sed '/^memsql/d' /etc/passwd > /tmp/_passwd && cat /tmp/_passwd > /etc/passwd && rm /tmp/_passwd
echo "memsql:saG0wPb9ztPZs:`id -u`:0:MemSQL Service Account:/var/lib/memsql-ops:/usr/bin/sh" >> /etc/passwd

/var/lib/memsql-ops/memsql-ops start --settings-file /data/settings.conf  --ignore-root-error -f 2>&1
