#!/bin/bash

DSAI_VERSION=1.0

truncate -s 0 build.log

for RELEASE in 7 6; do
    docker build --build-arg RELEASE=${RELEASE} --build-arg DSAI_VERSION=${DSAI_VERSION} -t anaconda-dsai-parcel-el${RELEASE} . 2>&1 | tee build.log

    docker run -v`pwd`:/root/out:Z anaconda-dsai-parcel-el${RELEASE}
done
