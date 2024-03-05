#!/bin/bash

INPUT_CHECKOUT=($INPUT_CHECKOUT)

[ "$(</etc/timezone)" != "America/New_York" ] &&
    echo "timezone-set=false" >>"$GITHUB_OUTPUT"

[ -z "$GH_TOKEN" ] &&
    echo "gh-token=false" >>"$GITHUB_OUTPUT"

! git status >/dev/null 2>&1 &&
    echo "checked-out=false" >>"$GITHUB_OUTPUT"

for option in "${INPUT_CHECKOUT[@]}"; do
    IFS='=' read -ra opt <<<"$option"
    if [ ! -z "${opt[0]}" ] && [ ! -z "${opt[1]}" ]; then
        echo "checkout_${opt[0]}=${opt[1]}" >>"$GITHUB_OUTPUT"
    else
        echo "\"$option\" is missing a key or value"
    fi
done
unset IFS
