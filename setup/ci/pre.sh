#!/bin/bash

echo ::group::Running setup-ci pre-checks...

echo - Checking event type
[ "$GITHUB_EVENT_NAME" != pull_request ] && {
    echo "::error::$ACTION_REPOSITORY/setup/ci can only run on \
\"pull_request\"."
    exit 1
}

echo - Checking for existing tags \& releases
if ! git describe --tags --abbrev=0 >/dev/null 2>&1 &&
    ! gh release view >/dev/null 2>&1; then
    echo gitversion-execute_overrideConfig=next-version=1.0.0 \
        >>"$GITHUB_OUTPUT"
fi

echo - Checking for project files
PROJ_FILES=($(find . -type f \( \
    -name '*.csproj' -o \
    -name '*.fsproj' -o \
    -name '*.vcproj' -o \
    -name '*.vcxproj' \)))

((${#PROJ_FILES[@]})) &&
    echo gitversion-execute_additionalArguments=/updateprojectfiles \
        >>"$GITHUB_OUTPUT"

echo ::endgroup::

exit 0
