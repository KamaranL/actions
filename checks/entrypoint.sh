#!/bin/bash

# FILES=(
#     github
#     git
#     path
# )
# JSON_TEMP="$RUNNER_TEMP/.json"
# [ ! -d "$JSON_TEMP" ] && mkdir -p "$JSON_TEMP"
# for file in "${FILES[@]}"; do
#     JSON="$JSON_TEMP/$file"
#     echo "{" >"$JSON"
#     echo "$file=$JSON" >>"$GITHUB_OUTPUT"
#     echo "::debug::>open($file)"
# done
# echo "files=${FILES[@]}" >>"$GITHUB_OUTPUT"
# echo "json_temp=$JSON_TEMP" >>"$GITHUB_OUTPUT"

echo hello from entrypoint
