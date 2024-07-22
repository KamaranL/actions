#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Checking for ci label in repository
IFS=$'\n' read -d '\n' -ra \
    labels <<<"$(gh label list --json name --jq .[].name \
        --repo "$GITHUB_REPOSITORY")" &&
    unset IFS

[[ ! " ${labels[@]} " =~ " ci " ]] &&
    gh label create ci --description "Workflow-related" --color 5319E7 \
        --repo "$GITHUB_REPOSITORY"

echo - Pulling logs from triggering workflow
log_dir="$RUNNER_TEMP/.log"
log_file="$log_dir/$WFR-${WFR_ID}_$WFR_ATTEMPT.log"
[ ! -d "$log_dir" ] && mkdir -p "$log_dir"

gh run view "$WFR_ID" --verbose --log \
    --attempt "$WFR_ATTEMPT" \
    --repo "$GITHUB_REPOSITORY" >"$log_file"

echo ::endgroup::

exit 0
