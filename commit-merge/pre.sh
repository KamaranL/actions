#!/usr/bin/env bash

echo ::group::bash "$0"

ACTION="${GITHUB_ACTION_PATH##*_actions\/}"

echo - Checking event type
[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo ::error::"$ACTION" can only run on \"pull_request \(open\)\".
    echo ::endgroup::
    exit 1
}

echo - Checking variable: GH_TOKEN
[ -z "$GH_TOKEN" ] && {
    echo ::error::GH_TOKEN not set.
    echo ::endgroup::
    exit 1
}

echo - Checking variable: CI_VERSION
[ -z "$CI_VERSION" ] && {
    echo ::error::CI_VERSION not set.
    echo ::endgroup::
    exit 1
}

echo - Checking variable: CI_SOURCE_BRANCH
[ -z "$CI_SOURCE_BRANCH" ] && {
    echo ::error::CI_SOURCE_BRANCH not set.
    echo ::endgroup::
    exit 1
}

echo ::endgroup::

exit 0
