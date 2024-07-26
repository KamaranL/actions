#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Checking variable: OP_SERVICE_ACCOUNT_TOKEN
[ -z "$OP_SERVICE_ACCOUNT_TOKEN" ] && {
    echo ::error::OP_SERVICE_ACCOUNT_TOKEN not set.
    echo ::endgroup::
    exit 1
}

echo ::endgroup::

exit 0
