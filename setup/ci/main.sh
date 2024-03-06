#!/bin/bash

if [ "${GITHUB_BASE_REF:-\$GITHUB_BASE_REF}" == main ] &&
    [[ ${GITHUB_HEAD_REF:-\$GITHUB_HEAD_REF} =~ ^dev(elop)?(ment)?$ ]]; then
    # echo "is-prerelease=false" >>"$GITHUB_OUTPUT"
    echo not prerelease
fi


echo running main
