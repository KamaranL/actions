#!/bin/bash

echo ::group::bash "$0"

echo - Checking event type
[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo "::error::${GITHUB_ACTION_PATH##*_actions/} can only run on \
\"pull_request\"."
    exit 1
}

echo ::endgroup::

exit 0
