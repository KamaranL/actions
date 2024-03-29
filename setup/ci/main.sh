#!/bin/bash

echo ::group::Setting up CI...

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
