#!/bin/bash

cd assets

curl -LO https://repo.continuum.io/archive/Anaconda3-5.3.1-Linux-x86_64.sh
chmod u+x Anaconda3-5.3.1-Linux-x86_64.sh

curl -LO https://download.pytorch.org/whl/cpu/torch-0.4.1-cp27-cp27mu-linux_x86_64.whl
curl -LO https://download.pytorch.org/whl/cpu/torch-0.4.1-cp35-cp35m-linux_x86_64.whl
curl -LO https://download.pytorch.org/whl/cpu/torch-0.4.1-cp36-cp36m-linux_x86_64.whl

cp ../../02-validator/validator.jar .
