#!/bin/bash

echo ::group::Running exec-cd-npm pre-checks...

echo - Checking package existence
npm view .@"$CI_VERSION" >/dev/null 2>&1 && {
    echo "::error::A package already exists for \"$CI_VERSION\"."
    exit 1
}

echo ::endgroup::

exit 0
