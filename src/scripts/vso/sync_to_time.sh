#!/usr/bin/env bash
#       
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
    
usage()
{
    echo "${0} HH:mm:ss"
    echo "example: ${0} 18:00:00"
}

sync_to_time()
{   
    if [[ -z ${1} ]]; then
        usage
        exit 1
    fi      
    local sync_time=$(date +"%a %b %d ${1} %Y %z")
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local commit_hash=$(git rev-list -n 1 --before="${sync_time}" "${current_branch}")
    if [[ -z ${commit_hash} ]]; then
        echo "Unable to obtain the commit hash before ${sync_time}"
        exit 1
    fi
    echo "Checking out to sync time: ${sync_time} -> hash: ${commit_hash}"
    git checkout ${commit_hash}
    return $?
}       
            
sync_to_time ${1}
exit $? 
