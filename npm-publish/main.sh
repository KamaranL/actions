#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Checking package
npm view .@"$CI_VERSION" &>/dev/null && {
    echo ::error::A package already exists for \""$CI_VERSION"\".
    echo ::endgroup::
    exit 1
}

echo - Publishing package
! npm publish 2>&1 && {
    echo ::error::There was a problem publishing package for \""$CI_VERSION"\".
    echo ::endgroup::
    exit 1
}

name="$(npm pkg get name --json | jq -r)"

echo "- :package: [**npm**]\
(https://www.npmjs.com/package/$name/v/$CI_VERSION)" \
    >>"$GITHUB_STEP_SUMMARY"

echo ::endgroup::

exit 0
