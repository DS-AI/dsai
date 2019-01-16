#!/bin/bash

echo ID NAME CGROUP

docker ps --filter "ancestor=dsai1.2" --format="{{.ID}} {{.Names}}" | while read ID NAMES; do
    echo $ID" "$NAMES" "`docker inspect $ID --format="{{.HostConfig.CgroupParent}}"`
done
