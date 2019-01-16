#!/bin/bash

truncate -s 0 build.log

docker build -t spark-patched . 2>&1 | tee build.log

docker run -v`pwd`:/root/out:Z spark-patched
