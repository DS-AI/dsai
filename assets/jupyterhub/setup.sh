#!/bin/bash

PATH=/opt/cloudera/parcels/Anaconda/bin:${PATH}

DEFAULT_ENV=`cat /opt/cloudera/parcels/Anaconda/envs/default`

if [ "${DEFAULT_ENV}" == "base" ]; then
    EXCLUDE_ENV="none"
else
    EXCLUDE_ENV="base"
fi

DEFAULT_ENV_PATH=`conda info --envs | fgrep -v '#' | awk '{ if ($1 == "'${DEFAULT_ENV}'") { print $NF; } }'`


KERNELS_PATH=${DEFAULT_ENV_PATH}/share/jupyter/kernels/


conda info --envs | fgrep -v '#' | awk '{ if (NF >= 2 && $1 != "'${EXCLUDE_ENV}'") { print $NF; } }' | while read E; do echo -e "import sys\nv = sys.version_info\nprint(v.major, v.minor)" | ${E}/bin/python | tr -d '(' | tr -d ')' | tr -d ',' | ( read MAJOR MINOR; if [ $MAJOR -ne 0 ]; then echo $E $MAJOR $MINOR; fi ); done | sort -r -k2,3 | awk '{ print $1" "$2; }' | uniq -f 1 | while read P V; do
    if echo ${P} | fgrep -q '/envs/'; then
        KERNEL_NAME=`basename ${P}`
    else
        KERNEL_NAME="base"
    fi

    mkdir -p ${KERNELS_PATH}/${KERNEL_NAME}

    sed 's+#PYTHON#+'${P}'/bin/python+g' /root/kernel-python-template.json | sed 's/#VERSION#/'$V'/g' > ${KERNELS_PATH}/${KERNEL_NAME}/kernel.json
done


PY4J_SPARK=`find /opt/cloudera/parcels/CDH/lib/spark -type f -name 'py4j*.zip'`
conda info --envs | fgrep -v '#' | awk '{ if (NF >= 2 && $1 != "'${EXCLUDE_ENV}'") { print $NF; } }' | while read E; do echo -e "import sys\nv = sys.version_info\nprint(0 if v.major == 3 and v.minor >= 6 else v.major, v.minor)" | ${E}/bin/python | tr -d '(' | tr -d ')' | tr -d ',' | ( read MAJOR MINOR; if [ $MAJOR -ne 0 ]; then echo $E $MAJOR $MINOR; fi ); done | sort -r -k2,3 | awk '{ print $1" "$2; }' | uniq -f 1 | while read P V; do
    if echo ${P} | fgrep -q '/envs/'; then
        KERNEL_NAME=`basename ${P}`-pyspark
    else
        KERNEL_NAME="base-pyspark"
    fi

    mkdir -p ${KERNELS_PATH}/${KERNEL_NAME}

    sed 's+#PYTHON#+'${P}'/bin/python+g' /root/kernel-python-spark-template.json | sed 's/#VERSION#/'$V'/g' | sed 's+#PY4J#+'${PY4J_SPARK}'+g' > ${KERNELS_PATH}/${KERNEL_NAME}/kernel.json
done


PY4J_SPARK2=`find /opt/cloudera/parcels/SPARK2/lib/spark2/ -type f -name 'py4j*.zip'`
conda info --envs | fgrep -v '#' | awk '{ if (NF >= 2 && $1 != "'${EXCLUDE_ENV}'") { print $NF; } }' | while read E; do echo -e "import sys\nv = sys.version_info\nprint(v.major, v.minor)" | ${E}/bin/python | tr -d '(' | tr -d ')' | tr -d ',' | ( read MAJOR MINOR; if [ $MAJOR -ne 0 ]; then echo $E $MAJOR $MINOR; fi ); done | sort -r -k2,3 | awk '{ print $1" "$2; }' | uniq -f 1 | while read P V; do
    if echo ${P} | fgrep -q '/envs/'; then
        KERNEL_NAME=`basename ${P}`-pyspark2
    else
        KERNEL_NAME="base"
    fi

    mkdir -p ${KERNELS_PATH}/${KERNEL_NAME}

    sed 's+#PYTHON#+'${P}'/bin/python+g' /root/kernel-python-spark2-template.json | sed 's/#VERSION#/'$V'/g' | sed 's+#PY4J#+'${PY4J_SPARK2}'+g' > ${KERNELS_PATH}/${KERNEL_NAME}/kernel.json
done


# Make Chrome 41 happy, see: https://github.com/jupyter/notebook/issues/3309.
find ${DEFAULT_ENV_PATH}/lib/python*/site-packages/notebook/static/ -type f -name '*.js' -exec fgrep -H '[fg, bg] = [bg, fg];' {} \; | awk -F':' '{ print $1; }' | while read F; do sed -i 's/\[fg, bg\] = \[bg, fg\];/_t = fg; fg = bg; bg = _t;/g' $F; done \
    && find ${DEFAULT_ENV_PATH}/lib/python*/site-packages/notebook/static/ -type f -name '*.js' -exec fgrep -H 'Array.from(files).forEach(' {} \; | awk -F':' '{ print $1; }' | while read F; do sed -i 's/Array\.from(files)\.forEach(/Array.prototype.forEach.call(files, /g' $F; done


source activate ${DEFAULT_ENV}

jupyter kernelspec uninstall -f python3

cp /root/dsai.py `echo -e "import sys\nprint([p for p in sys.path if p.endswith('/site-packages')][0])" | python`/
