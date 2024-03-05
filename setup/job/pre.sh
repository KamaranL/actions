#!/bin/bash

INPUT_CHECKOUT=($INPUT_CHECKOUT)

[ "$(</etc/timezone)" != "America/New_York" ] &&
    echo "timezone-set=false" >>"$GITHUB_OUTPUT"

[ -z "$GH_TOKEN" ] &&
    echo "gh-token=false" >>"$GITHUB_OUTPUT"

! git status >/dev/null 2>&1 &&
    echo "checked-out=false" >>"$GITHUB_OUTPUT"

# echo "count: ${#INPUT_CHECKOUT[@]}"
# echo "index 1: ${INPUT_CHECKOUT[1]}"
# echo -e "all: ${INPUT_CHECKOUT[*]}"

IFS='='
for option in "${INPUT_CHECKOUT[@]}"; do
    read -ra opt
    echo "${opt[0]} -- ${opt[1]}"
done
