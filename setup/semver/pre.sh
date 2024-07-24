#!/usr/bin/env bash

echo ::group::bash "$0"

declare -A out env
declare -a overrideConfig

ACTION="${GITHUB_ACTION_PATH##*_actions\/}"

echo - Checking event type
[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo ::error::"$ACTION" can only run on \"pull_request \(open\)\".
    echo ::endgroup::
    exit 1
}

echo - Checking for \"VERSION.txt\"
[ ! -f VERSION.txt ] && {
    echo ::error::"$ACTION" was unable to find \"VERSION.txt\" in the current \
        workspace.
    echo ::endgroup::
    exit 1
}

echo - Checking source \& target branches
if [ "$GITHUB_BASE_REF" == main ]; then
    ! [[ "$GITHUB_HEAD_REF" =~ ^dev(elop)?(ment)?$ ]] && {
        echo ::error::Branch \"$GITHUB_HEAD_REF\" is not a development \
            branch, and therefore not allowed to merge into \
            \"$GITHUB_BASE_REF\". Merge \"$GITHUB_HEAD_REF\" into a \
            development branch first.
        echo ::endgroup::
        exit 1
    }
else
    prerelease=true
    overrideConfig+=("continuous-delivery-fallback-tag=alpha")
fi

env[CI_PRERELEASE]=${prerelease:-false}
env[CI_SOURCE_BRANCH]="$GITHUB_HEAD_REF"
env[CI_SOURCE_SHA]="$PR_HEAD_SHA"
env[CI_TARGET_BRANCH]="$GITHUB_BASE_REF"
env[CI_TARGET_SHA]="$PR_BASE_SHA"

out[additionalArguments]="\
/url \"$GITHUB_SERVER_URL/$GITHUB_REPOSITORY\" \
/u \"$GITHUB_REPOSITORY_OWNER\" \
/p \"$GH_TOKEN\" \
/b \"$GITHUB_HEAD_REF\" \
/c \"$PR_BASE_SHA\" \
"

echo - Checking for existing tags \& releases
if ! git describe --tags --abbrev=0 &>/dev/null &&
    ! gh release view &>/dev/null; then
    overrideConfig+=("next-version=1.0.0")
fi

echo - Checking for common nuget package files
IFS=$'\n' read -d '\n' -ra nuget_files <<<"$(find . -type f \( \
    -name '*.sln' -o \
    -name '*.ps1' -o \
    -name '*.psd1' -o \
    -name 'nuget.config' \))" &&
    unset IFS
((${#nuget_files[@]})) &&
    nuget=true

echo - Checking for Visual Studio project files
IFS=$'\n' read -d '\n' -ra project_files <<<"$(find . -type f \( \
    -name '*.csproj' -o \
    -name '*.fsproj' -o \
    -name '*.vcproj' -o \
    -name '*.vcxproj' \))" &&
    unset IFS
((${#project_files[@]})) && {
    nuget=true
    out[additionalArguments]+="/updateprojectfiles "
}

env[CI_NUGET]=${nuget:-false}

{
    echo 'overrideConfig<<EOF'
    printf "%s\n" "${overrideConfig[@]}"
    echo EOF
} >>"$GITHUB_OUTPUT"

for k in "${!env[@]}"; do
    v="${env[$k]}"
    echo "$k=$v" >>"$GITHUB_ENV"
done
unset k v

for k in "${!out[@]}"; do
    v="${out[$k]}"
    echo "$k=$v" >>"$GITHUB_OUTPUT"
done

echo ::endgroup::

exit 0
