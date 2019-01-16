#!/bin/bash

ANACONDA_PATH=`cat /root/anaconda-path`

ARCH="el"$1

VERSION=$( basename `cat /root/anaconda-path` | cut -d'-' -f2- )

sed -i "s/#VERSION#/${VERSION}/" /root/parcel.json
sed -i "s/#ARCH#/${ARCH}/" /root/parcel.json

mkdir ${ANACONDA_PATH}/meta/

cp /root/parcel.json ${ANACONDA_PATH}/meta/
cp /root/conda_env.sh ${ANACONDA_PATH}/meta/

cd ${ANACONDA_PATH}

cd ..

tar zcvf Anaconda-${VERSION}-${ARCH}.parcel Anaconda-${VERSION}/ --owner=root --group=root
