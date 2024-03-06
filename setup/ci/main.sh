#!/bin/bash

echo "::group::Configuring CI..."

CI_SOURCE_BRANCH="${GITHUB_HEAD_REF:-\$GITHUB_HEAD_REF}"
CI_VERSION="$GitVersion_MajorMinorPatch"

if [ "${GITHUB_BASE_REF:-\$GITHUB_BASE_REF}" == main ] &&
    [[ ${GITHUB_HEAD_REF:-\$GITHUB_HEAD_REF} =~ ^dev(elop)?(ment)?$ ]]; then
    PRERELEASE=false
else
    PRERELEASE=true
fi

$PRERELEASE && {
    echo "Appending prerelease tag (alpha)"

    CI_VERSION+="alpha"

    # check for files that are commonly found in nuget packages
    NU_FILES=($(find . -type f \( \
        -name '*.sln' -o \
        -name '*.ps1' -o \
        -name '*.psd1' -o \
        -name 'nuget.config' \)))

    # append period in prerelease tag if not a nuget package
    ((!${#NU_FILES[@]})) &&
        CI_VERSION+="."

    CI_VERSION+="$GitVersion_CommitsSinceVersionSource"
}

echo "branch :  $CI_SOURCE_BRANCH"
echo "version:  $CI_VERSION"

echo "CI_SOURCE_BRANCH=$CI_SOURCE_BRANCH"
echo "CI_VERSION=$CI_VERSION"

echo "::endgroup::"
