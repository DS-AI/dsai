#!/bin/bash

docker build -t cloudera-manager-api . 2>&1 | tee build.log

docker run -v`pwd`:/root/out:Z cloudera-manager-api
