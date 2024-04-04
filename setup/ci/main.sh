#!/bin/bash

declare -A env

echo ::group::Executing "${GITHUB_ACTION_PATH##*_actions\/}"

env[CI_VERSION]="$GitVersion_MajorMinorPatch"

$CI_PRERELEASE && {
    echo - Appending prerelease tag: "$GitVersion_PreReleaseTagWithDash"
    env[CI_VERSION]+="$GitVersion_PreReleaseTagWithDash"

    $NU_PKG &&
        nu_pkg_version=$GitVersion_NuGetVersion
}
env[NU_PKG_VERSION]="${NU_PKG_VERSION:-$GitVersion_MajorMinorPatch}"

for k in "${!env[@]}"; do
    v="${env[$k]}"
    echo "$k=$v" >>"$GITHUB_ENV"
done

echo ::endgroup::

exit 0
