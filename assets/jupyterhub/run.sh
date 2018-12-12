#!/bin/bash

ANACONDA_PATH="/opt/cloudera/parcels/Anaconda/"

DEFAULT_ENV=`cat ${ANACONDA_PATH}/envs/default`

source activate ${DEFAULT_ENV}

if [ -z "${JUPYTERHUB_CLIENT_ID}" ]; then
    jupyterhub -f /etc/dsai/jupyterhub/jupyterhub_config.py
else
    for BINARY in spark-shell pyspark spark2-shell pyspark2; do
        echo -e '#!/bin/bash\n'`which ${BINARY}`" "${SPARK_SUBMIT_ARGS}' "$@"' > /opt/dsai/bin/${BINARY}

        chmod a+x /opt/dsai/bin/${BINARY}
    done

    HOME=`eval echo ~${JUPYTERHUB_USER}`

    cd ~ && su ${JUPYTERHUB_USER} -p -c "jupyterhub-singleuser --KernelSpecManager.ensure_native_kernel=False --ip=0.0.0.0"
fi
