#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Checking variable: CI_TAG
[ -z "$CI_TAG" ] && {
    echo ::error::CI_TAG not set.
    echo ::endgroup::
    exit 1
}

echo ::endgroup::

exit 0
