#!/bin/bash

[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo "::error::$ACTION_REPOSITORY/exec/ci can only run on \"pull_request\"."
    exit 1
}

exit 0
