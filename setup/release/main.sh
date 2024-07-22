#!/usr/bin/env bash

declare -A env

echo ::group::bash "$0"

echo - Getting recently pushed tag
pr="$(echo -e "$WFR_REF" | grep -oE '[0-9]{1,}')"
base_ref="$(gh pr view "$pr" --json baseRefName --jq .baseRefName)"
env[CI_VERSION]="$(curl -s \
    -H "Authorization: Token $GH_TOKEN" \
    -L "https://raw.githubusercontent.com/$GITHUB_REPOSITORY/${base_ref:-HEAD}\
/VERSION.txt")"
env[CI_TAG]="v${env[CI_VERSION]}"

echo - Switching ref to tags/"${env[CI_TAG]}"
git checkout tags/"${env[CI_TAG]}"

for k in "${!env[@]}"; do
    v="${env[$k]}"
    echo "$k=$v" >>"$GITHUB_ENV"
done

echo "# ${env[CI_TAG]} :arrow_right:" >>"$GITHUB_STEP_SUMMARY"

echo ::endgroup::

exit 0
