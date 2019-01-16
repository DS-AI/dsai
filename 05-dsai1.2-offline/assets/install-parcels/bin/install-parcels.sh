#!/bin/bash

mkdir /root/target

CLOUDERA_MANAGER_API_JAR=`find /root/lib/ -name 'cloudera-manager-api-*.jar'`

javac -d /root/target /root/src/InstallParcels.java -cp ${CLOUDERA_MANAGER_API_JAR}

if [ $? -ne 0 ]; then
    exit 1;
fi

CLUSTER_VERSION=`rpm -q --qf "%{VERSION} " cloudera-manager-server`

PARCEL_VERSIONS=
for F in `ls -1 /opt/cloudera/parcel-repo/*.parcel`; do
    PARCEL_VERSION=$( tar xzfO $F `basename $F | awk '{ print substr($0, 1, length($0) - length("-el7.parcel")); }'`/meta/parcel.json | jq '.name, .version' | tr -d '"' | tr '\n' ' ' )

    if [ -z "${PARCEL_VERSION}" ]; then
        exit 1;
    fi

    PARCEL_VERSIONS=${PARCEL_VERSIONS}${PARCEL_VERSION}
done

java -Djava.util.logging.config.file=/root/res/logging.properties -cp `find /root/lib/ -print0 | tr '\0' ':'`:/root/target InstallParcels ${CLUSTER_VERSION} ${PARCEL_VERSIONS}
