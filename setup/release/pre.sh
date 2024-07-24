#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Checking variable: GH_TOKEN
[ -z "$GH_TOKEN" ] && {
    echo ::error::GH_TOKEN not set.
    echo ::endgroup::
    exit 1
}

echo ::endgroup::

exit 0
