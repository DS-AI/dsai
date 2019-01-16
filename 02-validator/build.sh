#!/bin/bash

docker build -t validator . 2>&1 | tee build.log

docker run -v`pwd`:/root/out:Z validator
