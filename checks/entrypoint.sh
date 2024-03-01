#!/bin/bash

INPUT_GITHUB='${{ inputs.github }}'
INPUT_GIT='${{ inputs.github }}'
INPUT_ALL='${{ fromJson(inputs.all) }}'
: ${INPUT_ALL:=false}

OUTPUT_GITHUB="{"
OUTPUT_GIT="{"
OUTPUT_PATH="{"

echo "INPUT_GITHUB is $INPUT_GITHUB"
echo "INPUT_GIT is $INPUT_GIT"
echo "INPUT_ALL is $INPUT_ALL"

[[ $INPUT_GITHUB =~ timezone-set ]] || $INPUT_ALL && {
    # echo "->check(github.timezone-set)"
    [ "$(</etc/timezone)" != "America/New_York" ] && val="false"
    # echo "$(<'${{ steps.file.outputs.github }}') \"timezone-set\": ${val:-true}," >'${{ steps.file.outputs.github }}'
    OUTPUT_GITHUB+=" \"timezone-set\": ${val:-true},"
} && unset val

echo "github=${OUTPUT_GITHUB%,*} }" >>"$GITHUB_OUTPUT"

exit 0
