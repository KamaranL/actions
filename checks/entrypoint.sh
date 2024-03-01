#!/bin/bash

: ${INPUT_ALL:=false} ${INPUT_GIT:=false} ${INPUT_GITHUB:=false}

declare -A out

out[name]=kam

OUTPUT_GITHUB="{"
OUTPUT_GIT="{"
OUTPUT_PATH="{"

[[ $INPUT_GITHUB =~ timezone-set ]] || $INPUT_ALL && {
    # echo "->check(github.timezone-set)"
    [ "$(</etc/timezone)" != "America/New_York" ] && val="false"
    # echo "$(<'${{ steps.file.outputs.github }}') \"timezone-set\": ${val:-true}," >'${{ steps.file.outputs.github }}'
    OUTPUT_GITHUB+=" \"timezone-set\": ${val:-true},"
} && unset val

echo "github=${OUTPUT_GITHUB%,*} }" >>"$GITHUB_OUTPUT"

echo "${out[name]}"

exit 0
