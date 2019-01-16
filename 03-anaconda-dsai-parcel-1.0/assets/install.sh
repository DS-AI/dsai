#!/bin/bash

ENVS="2.7 3.5 3.6.6"
ENV_NAME_PREFIX="python"
DEFAULT_ENV="${ENV_NAME_PREFIX}3.6.6"
#DEFAULT_ENV=base

if [ ${DEFAULT_ENV} != "base" ] && ! for P in ${ENVS}; do echo ${ENV_NAME_PREFIX}${P}; done | tr ' ' '\n' | grep -q "^${DEFAULT_ENV}$"; then
    exit 1;
fi

DSAI_VERSION="dsai$2"

ANACONDA_INSTALLER=`ls -1 /root/Anaconda*.sh`
ANACONDA_VERSION=`echo ${ANACONDA_INSTALLER} | awk -F'-' '{print $2;}'`
ANACONDA_PATH="/opt/cloudera/parcels/Anaconda-${ANACONDA_VERSION}-${DSAI_VERSION}"

PATH="${ANACONDA_PATH}/bin:$PATH"

"${ANACONDA_INSTALLER}" -b -p "${ANACONDA_PATH}"

rm "${ANACONDA_INSTALLER}"


yum install -y boost boost-devel gcc-c++ make python-devel zlib zlib-devel



for P in $ENVS; do
    conda create -n ${ENV_NAME_PREFIX}${P} python=${P}
done


source activate ${DEFAULT_ENV}

echo ${DEFAULT_ENV} > ${ANACONDA_PATH}/envs/default

conda install -y -c conda-forge jupyterhub

source deactivate



declare -A EXTRA_LIBS

EXTRA_LIBS["${ENV_NAME_PREFIX}2.7-el6"]="/root/torch-0.4.1-cp27-cp27mu-linux_x86_64.whl"
EXTRA_LIBS["${ENV_NAME_PREFIX}3.5-el6"]="/root/torch-0.4.1-cp35-cp35m-linux_x86_64.whl"
EXTRA_LIBS["${ENV_NAME_PREFIX}3.6.6-el6"]="/root/torch-0.4.1-cp36-cp36m-linux_x86_64.whl"
EXTRA_LIBS["${ENV_NAME_PREFIX}2.7-el7"]="/root/torch-0.4.1-cp27-cp27mu-linux_x86_64.whl vowpalwabbit"
EXTRA_LIBS["${ENV_NAME_PREFIX}3.5-el7"]="/root/torch-0.4.1-cp35-cp35m-linux_x86_64.whl vowpalwabbit"
EXTRA_LIBS["${ENV_NAME_PREFIX}3.6.6-el7"]="/root/torch-0.4.1-cp36-cp36m-linux_x86_64.whl vowpalwabbit"

for P in $ENVS; do
    if [ ${ENV_NAME_PREFIX}${P} != ${DEFAULT_ENV} ]; then
        EXTRA_LIBS[$P]=${EXTRA_LIBS[$P]}" ipython ipykernel"
    fi
done


for P in `( for Q in $ENVS; do echo ${ENV_NAME_PREFIX}${Q}; done; echo ${DEFAULT_ENV} ) | tr ' ' '\n' | sort -u | tr '\n' ' '`; do
    source activate ${P}

    KEY="${P}-el$1"

    PIP_LIBS="beautifulsoup4 bokeh catboost category_encoders dill eli5 flask flask-cors gensim graphviz h2o heamy holoviews hyperopt ipywidgets keras lifelines lightgbm matplotlib mlxtend networkx nltk numpy opencv-python pandas plotly pymorphy2 pymorphy2-dicts pymorphy2-dicts-ru pyodbc request scikit-optimize scipy seaborn shap sklearn statsmodels tensorflow torchvision tqdm xgboost xmltodict ${EXTRA_LIBS[$KEY]}"

    pip install ${PIP_LIBS}

    cp /root/*.py `echo -e "import sys\nprint([p for p in sys.path if p.endswith('/site-packages')][0])" | python`/

    source deactivate
done

echo ${ANACONDA_PATH} > /root/anaconda-path
