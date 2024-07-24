#!/usr/bin/env bash

echo ::group::bash "$0"

declare -A out

echo - Checking for \$GH_TOKEN
[ -z "$GH_TOKEN" ] &&
    out[gh_token]=false

echo - Checking for repo in workspace
! git status &>/dev/null && {
    out[repository]=false
    checkout_defaults=(
        "repository=$GITHUB_REPOSITORY"
        "ref=${GITHUB_HEAD_REF:-$GITHUB_REF}"
        # "token= ## using GH_TOKEN (PAT)
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
    IFS=$'\n' read -d '\n' -ra checkout <<<"$INPUTS_CHECKOUT" &&
        unset IFS

    echo - Parsing input for checkout parameters
    for def_param in "${checkout_defaults[@]}"; do
        key="${def_param%%=*}"
        val="${def_param#*=}"

        for line in "${checkout[@]}"; do
            IFS='=' read -ra param <<<"$line" &&
                unset IFS
            p_key="${param[0]}"
            p_val="${param[1]}"

            [ "$key" == "$p_key" ] &&
                [ ! -z "$p_val" ] &&
                val="$p_val" &&
                break
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
