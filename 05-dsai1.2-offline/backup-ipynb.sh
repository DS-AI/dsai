#!/bin/bash

find /var/jupyterhub/home/ -name '*.ipynb' | fgrep -v '.ipynb_checkpoints' | while read F; do D=`dirname ".$F"`; mkdir -p $D; cp "$F" "$D"; done

