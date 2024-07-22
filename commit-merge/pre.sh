#!/usr/bin/env bash

echo ::group::bash "$0"

ACTION="${GITHUB_ACTION_PATH##*_actions\/}"

echo - Checking event type
[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo ::error::"$ACTION" can only run on \"pull_request \(open\)\".
    exit 1
}

echo ::endgroup::

exit 0
