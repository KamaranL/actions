#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Checking variable: OP_SERVICE_ACCOUNT_TOKEN
[ -z "$OP_SERVICE_ACCOUNT_TOKEN" ] && {
    echo ::error::OP_SERVICE_ACCOUNT_TOKEN not set.
    echo ::endgroup::
    exit 1
}

echo - Checking variable: CI_VERSION
[ -z "$CI_VERSION" ] && {
    echo ::error::CI_VERSION not set.
    echo ::endgroup::
    exit 1
}

echo ::endgroup::

exit 0
