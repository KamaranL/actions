#!/bin/bash

# set global defaults
: \
    ${INPUT_ALL:=false} \
    ${INPUT_GIT:=false} \
    ${INPUT_GITHUB:=false}

declare -A out

outputs=(
    git
    github
    path
)

for name in "${outputs[@]}"; do out[$name]="{"; done

[[ $INPUT_GITHUB =~ timezone-set ]] || $INPUT_ALL && {
    echo "->check(github.timezone-set)"
    [ "$(</etc/timezone)" != "America/New_York" ] && val=false
    out[github]+=" \"timezone-set\": ${val:-true},"
} && unset val

for name in "${outputs[@]}"; do
    echo "$name=${out[$name]%,*}" >>"$GITHUB_OUTPUT"
done

exit 0
