#!/bin/bash

docker ps | fgrep 'dsai1.2' | fgrep -v 'jupyter-' | awk '{ print $1; }' | while read ID; do docker exec $ID /bin/bash -c "kill \$( cat /root/jupyterhub.pid )"; done
