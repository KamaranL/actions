#!/bin/bash

echo ::group::Running "${GITHUB_ACTION_PATH##*_actions\/}" pre-checks...

declare -A out
inputs_checkout=($INPUTS_CHECKOUT)
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
    out["timezone-set"]=false

echo - Checking for \$GH_TOKEN
[ -z "$GH_TOKEN" ] &&
    out["gh-token"]=false

echo - Checking for repo in workspace
! git status >/dev/null 2>&1 && {
    out["checked-out"]=false

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
        out["checkout_$key"]="$val"
    done
}

for k in "${!out[@]}"; do
    v="${out[$k]}"
    echo "$k=$v" >>"$GITHUB_OUTPUT"
done

echo ::endgroup::

exit 0
