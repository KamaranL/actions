#!/bin/bash

declare -A env

echo ::group::bash "$0"

env[CI_VERSION]="$GitVersion_MajorMinorPatch"

$CI_PRERELEASE && {
    echo - Appending prerelease tag: "$GitVersion_PreReleaseTagWithDash"
    env[CI_VERSION]+="$GitVersion_PreReleaseTagWithDash"

    $NU_PKG &&
        nu_pkg_version=$GitVersion_NuGetVersion
}
env[NU_PKG_VERSION]="${nu_pkg_version:-$GitVersion_MajorMinorPatch}"

for k in "${!env[@]}"; do
    v="${env[$k]}"
    echo "$k=$v" >>"$GITHUB_ENV"
done

echo ::endgroup::

exit 0
