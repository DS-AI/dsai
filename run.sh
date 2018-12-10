#!/bin/bash

#docker run -p8000:8000 -p8888:8888 -p30000-30063:30000-30063 -p31000-31063:31000-31063 -v/var/lib/pbis/.lsassd:/var/lib/pbis/.lsassd:Z -v/var/lib/pbis/.netlogond:/var/lib/pbis/.netlogond:Z -v/var/jupyterhub/home:/home/BANK/:Z -v/tmp:/host/tmp:Z -v/etc/dsai/krb5.conf:/etc/krb5.conf:ro -v/etc/dsai/:/etc/dsai/:ro -v/etc/hosts:/etc/hosts:ro -e SPARK_LOCAL_IP=`hostname -f` dsai1.1

VOLUMES="-v/etc/passwd:/etc/passwd:ro -v/etc/group:/etc/group:ro -v/etc/shadow:/etc/shadow:ro -v/var/run/docker.sock:/var/run/docker.sock:Z -v/var/lib/pbis/.lsassd:/var/lib/pbis/.lsassd:Z -v/var/lib/pbis/.netlogond:/var/lib/pbis/.netlogond:Z -v/var/jupyterhub/home:/home/BANK/:Z -v/tmp:/host/tmp:Z -v/etc/dsai/krb5.conf:/etc/krb5.conf:ro -v/etc/dsai-docker/:/etc/dsai/:ro -v/etc/hosts:/etc/hosts:ro"

docker run -p0.0.0.0:8000:8000/tcp ${VOLUMES} -e VOLUMES="${VOLUMES}" -e HOST_HOSTNAME=`hostname -f` dsai1.2
