#!/bin/bash
# error handling.  https://stackoverflow.com/a/6482403
if [ -z "$1" ]; then
    echo "please supply a directory to scan"
    exit 1
fi
if [ -z "$2" ]; then
    echo "please supply destination file path"
    exit 1
fi
if [ -z "$3" ]; then
    echo "please supply an API key"
    exit 1
fi



#setting needed variables for script
target=$1
dest=$2
apiKey=$3

syft -o cyclonedx $target | \
    cyclonedx add files --input-format xml --output-format json | \
    jq -M '{projectName: "homeassistant-core", autoCreate: true, bom: @base64, projectVersion: "1"}' | \
    curl $dest \
        -X'PUT' \
        --data-binary @- \
        -H 'Content-Type: application/json' \
        -H "X-API-Key: $apiKey" \

# 23 taking output of syft in cyclonedx format.  Target is mounted volume directory.
# the homeassistant project is in this directory
# 24 cyclonedx is the forrmat that dependencytrack needs.
# 25 used jq to assemble the payload in the correct format for the dependencytrack api
# encoding to base64 as required by Dependencytrack
# 27 Using curl to send a PUT request to dependencytrack API
# 28 used to pipe next command to curl https://stackoverflow.com/a/25049637
# 29 & 30 http headers
# got API key from dependencytrack UI.  Had to set "project creation upload" permission
