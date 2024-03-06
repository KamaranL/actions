#!/bin/bash

# [ "$GITHUB_EVENT_NAME" != pull_request ] && {
#     echo "::error::$ACTION_REPOSITORY can only run on \"pull_request\""
#     exit 2
# }

if git describe --tags --abbrev=0 >/dev/null 2>&1 &&
    gh release view --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
    echo "gitversion-execute_overrideConfig=$(
        cat <<DOC
next-version=1.0.0
DOC
    )" >>"$GITHUB_OUTPUT"
fi
