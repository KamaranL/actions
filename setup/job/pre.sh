#!/bin/bash

INPUT_CHECKOUT=($INPUT_CHECKOUT)

[ "$(</etc/timezone)" != "America/New_York" ] &&
    echo "timezone-set=false" >>"$GITHUB_OUTPUT"

[ -z "$GH_TOKEN" ] &&
    echo "gh-token=false" >>"$GITHUB_OUTPUT"

! git status >/dev/null 2>&1 &&
    echo "checked-out=false" >>"$GITHUB_OUTPUT"


echo "${#INPUT_CHECKOUT[@]}"
echo "${INPUT_CHECKOUT[1]}"


# for input in "${INPUT_CHECKOUT[@]}"; do
#     echo "$input"
# done
