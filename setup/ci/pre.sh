#!/bin/bash

[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo "::error::$ACTION_REPOSITORY/setup/ci can only run on \"pull_request\"."
    exit 1
}

# force 1.0.0 if no existing tag or release is found
if ! git describe --tags --abbrev=0 >/dev/null 2>&1 &&
    ! gh release view --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
    echo "gitversion-execute_overrideConfig=next-version=1.0.0" >>"$GITHUB_OUTPUT"
fi

exit 0
