#!/bin/bash

[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo "::error::$ACTION_REPOSITORY can only run on \"pull_request\""
    echo "::error::$GITHUB_ACTION_REPOSITORY c@n only run on \"pull_request\""
    exit 2
}
