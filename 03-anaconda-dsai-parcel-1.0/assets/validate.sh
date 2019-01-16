#!/bin/bash

ANACONDA_PATH=`cat /root/anaconda-path`

VERSION=$( basename `cat /root/anaconda-path` | cut -d'-' -f2- )

ARCH="el"$1

cd ${ANACONDA_PATH}

cd ..

java -jar /root/validator.jar -p ${ANACONDA_PATH}/meta/parcel.json
java -jar /root/validator.jar -d ${ANACONDA_PATH}
java -jar /root/validator.jar -f Anaconda-${VERSION}-${ARCH}.parcel 
