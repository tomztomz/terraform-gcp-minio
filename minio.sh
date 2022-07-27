#!/bin/bash
yum update -y

# Set timezone
timedatectl set-timezone Asia/Bangkok

# Disable SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
yum install -y vim bind-utils.x86_64 traceroute git wget


#### Install Minio ####
cd /opt
#wget https://dl.min.io/server/minio/release/linux-amd64/minio
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio-20210617001046.0.0.x86_64.rpm
rpm -ivh minio-20210617001046.0.0.x86_64.rpm
#chmod +x minio
# ./minio server /data
mkdir /minio_data

cat > /etc/default/minio <<EOF
# Volume to be used for MinIO server.
MINIO_VOLUMES="/minio_data"
# Use if you want to run MinIO on a custom port.
MINIO_OPTS="--address :9000"
# Access Key of the server.
MINIO_ACCESS_KEY=w4Q5e5xC4
# Secret key of the server.
MINIO_SECRET_KEY=53tWA3a38
# Set no listing files
#MINIO_BROWSER=off
EOF

cat > /etc/systemd/system/minio.service <<EOF
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio
[Service]
WorkingDirectory=/usr/local
User=root
#Group=root
EnvironmentFile=/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"\${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server \$MINIO_OPTS \$MINIO_VOLUMES
# Let systemd restart this service always
Restart=always
# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536
# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no
[Install]
WantedBy=multi-user.target
# Built for \${project.name}-\${project.version} (\${project.name})
EOF
systemctl daemon-reload
systemctl enable minio.service
systemctl start minio

echo "=============Install MinIO server done================="

cd /opt
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
./mc --help

ln -s /opt/mc /bin/mc
echo "=============Install MinIO Client done================="
echo "Add Storage server"
echo "Example mc alias set minio http://<server-ip>:9000 [key] [secrete_key]"
echo "https://docs.min.io/docs/minio-client-complete-guide.html"