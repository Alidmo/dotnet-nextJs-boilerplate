#!/bin/bash
set -e

# Expects one parameter: projectName
projectName="$1"
HOST_ENTRY="127.0.0.1 my.${projectName}.local"

if grep -q "my.${projectName}.local" /etc/hosts; then
    echo "Host entry for my.${projectName}.local already exists in /etc/hosts."
else
    echo "Adding host entry to /etc/hosts: ${HOST_ENTRY}"
    echo "${HOST_ENTRY}" | sudo tee -a /etc/hosts > /dev/null
fi
