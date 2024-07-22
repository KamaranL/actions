#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Checking tag existence
[ -z "$CI_TAG" ] && {
    echo ::error::No tag was found for release.
    exit 1
}

echo - Checking release existence
gh release view "$CI_TAG" &>/dev/null && {
    echo ::error::A release already exists for \""$CI_TAG"\".
    exit 1
}

echo ::endgroup::

exit 0
