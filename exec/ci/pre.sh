#!/bin/bash

echo ::group::Running exec-ci pre-checks...

echo - Checking event type
[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo "::error::${GITHUB_ACTION_PATH##*_actions/} can only run on \
\"pull_request\"."
    exit 1
}

echo ::endgroup::

exit 0
