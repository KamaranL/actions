#!/bin/bash

echo ::group::Running exec-issue pre-checks...

EXIST=false
LABELS=($(gh label list --json name --jq .[].name --repo "$GITHUB_REPOSITORY"))

for LABEL in "${LABELS[@]}"; do
    [ "$LABEL" == ci ] && {
        EXIST=true
        break
    }
done

echo - Checking for ci label in repository
! $EXIST &&
    gh label create ci --description "Workflow-related" --color 5319E7 \
        --repo "$GITHUB_REPOSITORY"

LOG_TEMP="$RUNNER_TEMP/.logs"
LOG_FILE="$LOG_TEMP/$WFR-${WFR_ID}_$WFR_ATTEMPT.log"
[ ! -d "$LOG_TEMP" ] && mkdir -p "$LOG_TEMP"

echo - Pulling logs from triggering workflow
gh run view $WFR_ID --verbose --log \
    --attempt $WFR_ATTEMPT \
    --repo "$GITHUB_REPOSITORY" >"$LOG_FILE"

echo ::endgroup::

exit 0
