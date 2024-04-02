#!/bin/bash

echo ::group::Executing "${GITHUB_ACTION_PATH##*_actions\/}"

CI_VERSION="$GitVersion_MajorMinorPatch"

$CI_PRERELEASE && {
    echo - Appending prerelease tag: "$GitVersion_PreReleaseTagWithDash"
    CI_VERSION+="$GitVersion_PreReleaseTagWithDash"

    $NU_PKG &&
        NU_PKG_VERSION=$GitVersion_NuGetVersion
}

echo "CI_VERSION=$CI_VERSION" >>"$GITHUB_ENV"
echo "NU_PKG_VERSION=${NU_PKG_VERSION:-$GitVersion_MajorMinorPatch}" \
    >>"$GITHUB_ENV"

echo ::endgroup::

exit 0
