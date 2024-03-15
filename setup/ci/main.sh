#!/bin/bash

echo "::group::Configuring CI..."

CI_SOURCE_BRANCH="${GITHUB_HEAD_REF:-\$GITHUB_HEAD_REF}"
CI_TARGET_BRANCH="${GITHUB_BASE_REF:-\$GITHUB_BASE_REF}"
CI_VERSION="$GitVersion_MajorMinorPatch"

if [ "$CI_TARGET_BRANCH" == main ]; then
    ! [[ $CI_SOURCE_BRANCH =~ ^dev(elop)?(ment)?$ ]] && {
        echo "::error::\"$CI_SOURCE_BRANCH\" is not a development branch and \
therefore not allowed to merge into \"$CI_TARGET_BRANCH\". Merge \
\"$CI_SOURCE_BRANCH\" into a development branch first."
        exit 1
    }
    PRERELEASE=false
else
    PRERELEASE=true
    PRERELEASE_TAG=-alpha
fi

$PRERELEASE && {
    echo "- Appending prerelease tag: $PRERELEASE_TAG"
    CI_VERSION+="$PRERELEASE_TAG"

    # check for files that are commonly found in nuget packages
    NU_FILES=($(find . -type f \( \
        -name '*.sln' -o \
        -name '*.ps1' -o \
        -name '*.psd1' -o \
        -name 'nuget.config' \)))

    # append period in prerelease tag if not a nuget package
    ! ((${#NU_FILES[@]})) &&
        CI_VERSION+="." ||
        echo "- Formatting as nuget-compatible version"

    echo "- Appending commit count: $GitVersion_CommitsSinceVersionSource"
    CI_VERSION+="$GitVersion_CommitsSinceVersionSource"
}

echo "CI_SOURCE_BRANCH: $CI_SOURCE_BRANCH"
echo "CI_TARGET_BRANCH: $CI_TARGET_BRANCH"
echo "CI_VERSION:       $CI_VERSION"

echo "CI_SOURCE_BRANCH=$CI_SOURCE_BRANCH" >>"$GITHUB_ENV"
echo "CI_TARGET_BRANCH=$CI_TARGET_BRANCH" >>"$GITHUB_ENV"
echo "CI_VERSION=$CI_VERSION" >>"$GITHUB_ENV"

echo "::endgroup::"

exit 0
