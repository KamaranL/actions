#!/bin/bash

echo ::group::Running setup-job pre-checks...

INPUT_CHECKOUT=($INPUT_CHECKOUT)
CHECKOUT_DEFAULTS=(
    "repository=$GITHUB_REPOSITORY"
    "ref="
    # "token= # using GH_TOKEN (PAT)
    "ssh-key="
    "ssh-known-hosts="
    "ssh-strict=true"
    "persist-credentials=true"
    "path="
    "clean=true"
    "filter="
    "sparse-checkout="
    "sparse-checkout-cone-mode=true"
    "fetch-depth=1"
    "fetch-tags=false"
    "show-progress=true"
    "lfs=false"
    "submodules=false"
    "set-safe-directory=true"
    "github-server-url="
)

echo - Checking for correct timezone
[ "$(</etc/timezone)" != America/New_York ] &&
    echo timezone-set=false >>"$GITHUB_OUTPUT"

echo - Checking for \$GH_TOKEN
[ -z "$GH_TOKEN" ] &&
    echo gh-token=false >>"$GITHUB_OUTPUT"

echo - Checking for repo in workspace
! git status >/dev/null 2>&1 && {
    echo checked-out=false >>"$GITHUB_OUTPUT"

    echo - Parsing input for checkout parameters
    for DEFAULT in "${CHECKOUT_DEFAULTS[@]}"; do
        KEY="${DEFAULT%%=*}"
        VAL="${DEFAULT#*=}"

        for LINE in "${INPUT_CHECKOUT[@]}"; do
            IFS='=' read -ra param <<<"$LINE"
            P_KEY="${param[0]}"
            P_VAL="${param[1]}"

            [ "$KEY" == "$P_KEY" ] &&
                [ ! -z "$P_VAL" ] &&
                VAL="$P_VAL" &&
                break
            unset IFS
        done
        echo - Setting "$KEY = $VAL"
        echo "checkout_$KEY=$VAL" >>"$GITHUB_OUTPUT"
    done
}

echo ::endgroup::
echo ::group::Setting up job...

exit 0
