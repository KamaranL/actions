#!/usr/bin/env bash

echo ::group::bash "$0"

declare -A out

echo - Checking variable: OP_SERVICE_ACCOUNT_TOKEN
[ -z "$OP_SERVICE_ACCOUNT_TOKEN" ] && {
    echo ::error::OP_SERVICE_ACCOUNT_TOKEN not set.
    echo ::endgroup::
    exit 1
}

echo - Checking git configuration
[ "$(git config --global user.email)" != "bot@kamaranl.vip" ] &&
    out[configured]=false

for k in "${!out[@]}"; do
    v="${out[$k]}"
    echo "$k=$v" >>"$GITHUB_OUTPUT"
done

echo ::endgroup::

exit 0
