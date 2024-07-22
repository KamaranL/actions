#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Checking package existence
npm view .@"$CI_VERSION" &>/dev/null && {
    echo ::error::A package already exists for \""$CI_VERSION"\".
    exit 1
}

echo ::endgroup::

exit 0
