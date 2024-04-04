#!/bin/bash

echo ::group::bash "$0"

echo - Checking package existence
npm view .@"$CI_VERSION" >/dev/null 2>&1 && {
    echo "::error::A package already exists for \"$CI_VERSION\"."
    exit 1
}

echo ::endgroup::

exit 0
