#!/bin/bash

docker build -t dsai1.2 . 2>&1 | tee build.log
