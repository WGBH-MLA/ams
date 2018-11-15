#!/bin/bash

result=$(curl -s -o /dev/null -I -w "%{http_code}" ams-edge.wgbh-mla.org)

if [[ result -eq 200 ]]; then
    exit 0
else
    exit 1
fi