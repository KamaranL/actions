#!/bin/bash

echo ::group::Setting up CI...

dotnet-gitversion

CI_VERSION="$GitVersion_MajorMinorPatch"

echo - Setting release type
if [ "$CI_TARGET_BRANCH" == main ]; then
    ! [[ $CI_SOURCE_BRANCH =~ ^dev(elop)?(ment)?$ ]] && {
        echo "::error::Branch \"$CI_SOURCE_BRANCH\" is not a development \
branch and therefore not allowed to merge into \"$CI_TARGET_BRANCH\". Merge \
\"$CI_SOURCE_BRANCH\" into a development branch first."
        exit 1
    }
    PRERELEASE=false
else
    PRERELEASE=true
    PRERELEASE_TAG=-alpha
fi

$PRERELEASE && {
    echo - Appending prerelease tag: "$PRERELEASE_TAG"
    CI_VERSION+="$PRERELEASE_TAG"

    # check for files that are commonly found in nuget packages
    NU_FILES=($(find . -type f \( \
        -name '*.sln' -o \
        -name '*.ps1' -o \
        -name '*.psd1' -o \
        -name 'nuget.config' \)))

    ! ((${#NU_FILES[@]})) &&
        CI_VERSION+="." ||
        echo - Formatting prerelease version as nuget-compatible

    echo - Appending commit count: "$GitVersion_CommitsSinceVersionSource"
    CI_VERSION+="$GitVersion_CommitsSinceVersionSource"
}

echo "CI_VERSION=$CI_VERSION" >>"$GITHUB_ENV"

echo ::endgroup::

exit 0
