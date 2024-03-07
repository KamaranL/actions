#!/bin/bash

INPUT_CHECKOUT=($INPUT_CHECKOUT)
CHECKOUT_DEFAULTS=(
    "repository=$GITHUB_REPOSITORY"
    "ref="
    # "token=$GITHUB_TOKEN" # using GH_TOKEN (PAT)
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

[ "$(</etc/timezone)" != "America/New_York" ] &&
    echo "timezone-set=false" >>"$GITHUB_OUTPUT"

[ -z "$GH_TOKEN" ] &&
    echo "gh-token=false" >>"$GITHUB_OUTPUT"

! git status >/dev/null 2>&1 &&
    echo "checked-out=false" >>"$GITHUB_OUTPUT"

for default in "${CHECKOUT_DEFAULTS[@]}"; do
    key="${default%%=*}"
    val="${default#*=}"

    for line in "${INPUT_CHECKOUT[@]}"; do
        IFS='=' read -ra param <<<"$line"
        p_key="${param[0]}"
        p_val="${param[1]}"

        [ "$key" != "$p_key" ] && continue
        [ ! -z "$p_val" ] &&
            val="$p_val"
        unset IFS
    done
    echo "checkout_$key=$val" >>"$GITHUB_OUTPUT"
done
