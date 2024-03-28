#!/bin/bash

echo ::group::Running setup-ci pre-checks...

# GVE_AA=""

echo - Checking event type
[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo "::error::$ACTION_REPOSITORY/setup/ci can only run on \
\"pull_request\"."
    exit 1
}

echo - Checking for existing tags \& releases
if ! git describe --tags --abbrev=0 >/dev/null 2>&1 &&
    ! gh release view >/dev/null 2>&1; then
    GVE_OC+="next-version=1.0.0\n"
fi

echo - Checking for project files
PROJ_FILES=($(find . -type f \( \
    -name '*.csproj' -o \
    -name '*.fsproj' -o \
    -name '*.vcproj' -o \
    -name '*.vcxproj' \)))

((${#PROJ_FILES[@]})) &&
    GVE_AA+="/updateprojectfiles"
# echo gitversion-execute_additionalArguments=/updateprojectfiles \
#     >>"$GITHUB_OUTPUT"

echo - Checking prerelease
if [ "$GITHUB_BASE_REF" == main ]; then
    ! [[ "$GITHUB_HEAD_REF" =~ ^dev(elop)?(ment)?$ ]] && {
        echo "::error::Branch \"$GITHUB_HEAD_REF\" is not a development \
branch and therefore not allowed to merge into \"$GITHUB_BASE_REF\". Merge \
\"$GITHUB_HEAD_REF\" into a development branch first."
        exit 1
    }
    PRERELEASE=false
else
    PRERELEASE=true
    PRERELEASE_LABEL=alpha
fi

GVE_OC+="continuous-delivery-fallback-tag=${PRERELEASE_LABEL:-ci}\n"
GVE_OC+="assembly-informational-format=\"{InformationalVersion}\"\n" # test

echo "gitversion-execute_overrideConfig=$(echo -e "$GVE_OC")" >>"$GITHUB_OUTPUT"
echo "gitversion-execute_additionalArguments=$GVE_AA" >>"$GITHUB_OUTPUT"

echo "CI_PRERELEASE=$PRERELEASE" >>"$GITHUB_ENV"
echo "CI_SOURCE_BRANCH=$GITHUB_HEAD_REF" >>"$GITHUB_ENV"
echo "CI_TARGET_BRANCH=$GITHUB_BASE_REF" >>"$GITHUB_ENV"
echo "CI_SOURCE_SHA=$PR_HEAD_SHA" >>"$GITHUB_ENV"
echo "CI_TARGET_SHA=$PR_BASE_SHA" >>"$GITHUB_ENV"

echo ::endgroup::

exit 0
