#!/bin/bash

echo ::group::Running setup-job pre-checks...

inputs_checkout=($INPUTS_CHECKOUT)
outputs=()
checkout_defaults=(
    "repository=$GITHUB_REPOSITORY"
    "ref=${GITHUB_HEAD_REF:-$GITHUB_REF}"
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
    outputs+=(timezone-set=false)
# echo timezone-set=false >>"$GITHUB_OUTPUT"

echo - Checking for \$GH_TOKEN
[ -z "$GH_TOKEN" ] &&
    outputs+=(gh-token=false)
# echo gh-token=false >>"$GITHUB_OUTPUT"

echo - Checking for repo in workspace
! git status >/dev/null 2>&1 && {
    outputs+=(checked-out=false)
    # echo checked-out=false >>"$GITHUB_OUTPUT"

    echo - Parsing input for checkout parameters
    for default in "${checkout_defaults[@]}"; do
        key="${default%%=*}"
        val="${default#*=}"

        for line in "${inputs_checkout[@]}"; do
            IFS='=' read -ra param <<<"$line"
            p_key="${param[0]}"
            p_val="${param[1]}"

            [ "$key" == "$p_key" ] &&
                [ ! -z "$p_val" ] &&
                val="$p_val" &&
                break
            unset IFS
        done
        echo - Setting "$key = $val"
        # echo "checkout_$key=$val" >>"$GITHUB_OUTPUT"
        outputs+=("checkout_$key=$val")
    done
}

for output in "${outputs[@]}"; do echo "$output" >>"$GITHUB_OUTPUT"; done

echo ::endgroup::

exit 0
