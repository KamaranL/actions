#!/bin/bash

echo ::group::Setting up CI...

CI_VERSION="$GitVersion_MajorMinorPatch"

$CI_PRERELEASE && {
    echo - Appending prerelease label: "$GitVersion_PreReleaseLabelWithDash"
    CI_VERSION+="$GitVersion_PreReleaseLabelWithDash"

    # check for files that are commonly found in nuget packages
    NU_FILES=($(find . -type f \( \
        -name '*.sln' -o \
        -name '*.ps1' -o \
        -name '*.psd1' -o \
        -name 'nuget.config' \)))

    ! ((${#NU_FILES[@]})) &&
        CI_VERSION+="." ||
        echo - Formatting prerelease version as nuget-compatible

    echo - Appending prerelease number: "$GitVersion_PreReleaseNumber"
    CI_VERSION+="$GitVersion_PreReleaseNumber"
}

echo "CI_VERSION=$CI_VERSION" >>"$GITHUB_ENV"

echo ::endgroup::

exit 0
