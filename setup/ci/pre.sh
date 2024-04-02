#!/bin/bash

echo ::group::Running "${GITHUB_ACTION_PATH##*_actions\/}" pre-checks...

env=(
    "CI_SOURCE_BRANCH=$GITHUB_HEAD_REF"
    "CI_SOURCE_SHA=$PR_HEAD_SHA"
    "CI_TARGET_BRANCH=$GITHUB_BASE_REF"
    "CI_TARGET_SHA=$PR_BASE_SHA"
)
gve_aa="\
/url \"$GITHUB_SERVER_URL/$GITHUB_REPOSITORY\" \
/u \"$GITHUB_REPOSITORY_OWNER\" \
/p \"$GH_TOKEN\" \
/b \"$GITHUB_HEAD_REF\" \
/c \"$PR_BASE_SHA\" \
"
gve_oc=()

echo - Checking event type
[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo "::error::${GITHUB_ACTION_PATH##*_actions\/} can only run on \
\"pull_request\"."
    exit 1
}

echo - Checking for existing tags \& releases
if ! git describe --tags --abbrev=0 >/dev/null 2>&1 &&
    ! gh release view >/dev/null 2>&1; then
    gve_oc+=("next-version=1.0.0")
fi

echo - Checking for common nuget package files
nu_files=($(find . -type f \( \
    -name '*.sln' -o \
    -name '*.ps1' -o \
    -name '*.psd1' -o \
    -name 'nuget.config' \)))
((${#nu_files[@]})) &&
    nu_pkg=true
env+=(NU_PKG=${nu_pkg:-false})

echo - Checking for project files
project_files=($(find . -type f \( \
    -name '*.csproj' -o \
    -name '*.fsproj' -o \
    -name '*.vcproj' -o \
    -name '*.vcxproj' \)))
((${#project_files[@]})) &&
    gve_aa+="/updateprojectfiles "

echo - Checking source/target branches
if [ "$GITHUB_BASE_REF" == main ]; then
    ! [[ "$GITHUB_HEAD_REF" =~ ^dev(elop)?(ment)?$ ]] && {
        echo "::error::Branch \"$GITHUB_HEAD_REF\" is not a development \
branch and therefore not allowed to merge into \"$GITHUB_BASE_REF\". Merge \
\"$GITHUB_HEAD_REF\" into a development branch first."
        exit 1
    }
else
    prerelease=true
    gve_oc+=("continuous-delivery-fallback-tag=alpha")
fi
env+=(CI_PRERELEASE=${prerelease:-false})

echo "gitversion-execute_additionalArguments=${gve_aa% *}" >>"$GITHUB_OUTPUT"
{
    echo 'gitversion-execute_overrideConfig<<EOF'
    for cfg in "${gve_oc[@]}"; do echo "$cfg"; done
    echo EOF
} >>"$GITHUB_OUTPUT"

# echo "CI_PRERELEASE=$PRERELEASE" >>"$GITHUB_ENV"
# echo "CI_SOURCE_BRANCH=$GITHUB_HEAD_REF" >>"$GITHUB_ENV"
# echo "CI_SOURCE_SHA=$PR_HEAD_SHA" >>"$GITHUB_ENV"
# echo "CI_TARGET_BRANCH=$GITHUB_BASE_REF" >>"$GITHUB_ENV"
# echo "CI_TARGET_SHA=$PR_BASE_SHA" >>"$GITHUB_ENV"
# echo "NU_PKG=$NU_PKG" >>"$GITHUB_ENV"

for e in "${env[@]}"; do echo "$e" >>"$GITHUB_ENV"; done

echo ::endgroup::

exit 0
