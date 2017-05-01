#!/bin/sh
host=${HDFS_HOST:-localhost}
port=${HDFS_PORT:-8020}
ssh_port=${SSH_PORT:-22}
export HADOOP_SSH_OPTS="-p ${ssh_port}"

init_config() {
    cp -f /opt/hadoop/etc/hadoop/core-site.xml.template /opt/hadoop/etc/hadoop/core-site.xml
    sed -i -e "s/HDFS_HOST/$host/" /opt/hadoop/etc/hadoop/core-site.xml
    sed -i -e "s/HDFS_PORT/$port/" /opt/hadoop/etc/hadoop/core-site.xml
    sed -i -e "s/Port 22/Port $ssh_port/" /etc/ssh/sshd_config
}

echo "Starting HDFS on ${host}:${port}"
init_config

service ssh start
until nc -vzw 2 $host ${ssh_port}; do sleep 2; done

start-dfs.sh \
  && hadoop-daemon.sh start portmap \
  && hadoop-daemon.sh start nfs3

sleep infinity
