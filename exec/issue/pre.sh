#!/bin/bash

echo ::group::bash "$0"

exists=false
labels=($(gh label list --json name --jq .[].name --repo "$GITHUB_REPOSITORY"))

for l in "${labels[@]}"; do
    [ "$l" == ci ] && {
        exists=true
        break
    }
done

echo - Checking for ci label in repository
! $exists &&
    gh label create ci --description "Workflow-related" --color 5319E7 \
        --repo "$GITHUB_REPOSITORY"

log_dir="$RUNNER_TEMP/.log"
log_file="$log_dir/$WFR-${WFR_ID}_$WFR_ATTEMPT.log"
[ ! -d "$log_dir" ] && mkdir -p "$log_dir"

echo - Pulling logs from triggering workflow
gh run view "$WFR_ID" --verbose --log \
    --attempt "$WFR_ATTEMPT" \
    --repo "$GITHUB_REPOSITORY" >"$log_file"

echo ::endgroup::

exit 0
