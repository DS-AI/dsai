#!/bin/bash

docker ps | fgrep 'dsai1.2' | fgrep -v 'jupyter-' | awk '{ print $1; }' | while read ID; do docker stop $ID; done

docker ps | fgrep 'dsai1.2' | fgrep 'jupyter-' | awk '{ print $1; }' | while read ID; do docker stop $ID; done

docker ps -a | fgrep 'dsai1.2' | awk '{ print $1; }' | while read ID; do docker rm $ID; done
