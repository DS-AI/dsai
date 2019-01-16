#!/bin/bash

ANACONDA_PATH="/opt/cloudera/parcels/Anaconda/"

DEFAULT_ENV=`cat ${ANACONDA_PATH}/envs/default`

source activate ${DEFAULT_ENV}

if [ -z "${JUPYTERHUB_CLIENT_ID}" ]; then
    while true; do
        jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
    done
else
    HOME=`su ${JUPYTERHUB_USER} -c 'echo ~'`

    cd ~

    su ${JUPYTERHUB_USER} -p -c "jupyterhub-singleuser --KernelSpecManager.ensure_native_kernel=False --ip=0.0.0.0"
fi
