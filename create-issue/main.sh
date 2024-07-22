#!/usr/bin/env bash

echo ::group::bash "$0"

title="${WFR_PATH##*\/} (#$WFR_NUMBER): $WFR_EVENT $WFR_CONCLUSION"
body="$(
    cat <<EOF
| Workflow      |                   |
| ------------- | ----------------- |
| Name          | [$WFR]($WFR_FILE) |
| Number        | $WFR_NUMBER       |
| ID            | $WFR_ID           |
| Attempt       | $WFR_ATTEMPT      |
| Event         | $WFR_EVENT        |
$(
        if [ "$WFR_EVENT" == pull_request ]; then
            cat <<DOC
| < Head Branch | $WFR_HEAD_REF     |
| < Head Commit | $WFR_HEAD_SHA     |
| > Base Branch | $WFR_BASE_REF     |
| > Base Commit | $WFR_BASE_SHA     |
DOC
        else
            cat <<DOC
| Branch        | $WFR_BRANCH       |
| Commit        | $WFR_SHA          |
DOC
        fi
    )
| Committer     | $WFR_COMMITTER    |

### Next steps

- Review [logs]($LOG_URL)
- Suggest fixes
EOF
)"

echo - Creating issue...
gh issue create \
    --assignee "$GITHUB_TRIGGERING_ACTOR" \
    --label ci \
    --title "$title" \
    --body "$body" \
    --repo "$GITHUB_REPOSITORY" 2>&1

echo ::endgroup::

exit 0
