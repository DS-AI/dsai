#!/bin/bash

cd `dirname "$0"`

CONFIG_DIR=`pwd`/config

VOLUMES="-v/var/run/docker.sock:/var/run/docker.sock:Z -v/var/lib/pbis/.lsassd:/var/lib/pbis/.lsassd:Z -v/var/lib/pbis/.netlogond:/var/lib/pbis/.netlogond:Z -v/var/jupyterhub/home:/home/BANK/:Z -v/u00/:/u00/:Z -v/tmp:/host/tmp:Z -v${CONFIG_DIR}/krb5.conf:/etc/krb5.conf:ro -v${CONFIG_DIR}/hadoop/:/etc/hadoop/conf.cloudera.yarn/:ro -v${CONFIG_DIR}/spark/:/etc/spark/conf.cloudera.spark_on_yarn/:ro -v${CONFIG_DIR}/spark2/:/etc/spark2/conf.cloudera.spark2_on_yarn/:ro -v${CONFIG_DIR}/jupyterhub/:/etc/jupyterhub/:ro"

docker run -p0.0.0.0:8000:8000/tcp ${VOLUMES} -e VOLUMES="${VOLUMES}" -e HOST_HOSTNAME=`hostname -f` dsai1.2
