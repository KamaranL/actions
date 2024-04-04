#!/bin/bash

declare -A out

echo ::group::bash "$0"

[ "$(git config --global user.email)" != "bot@kamaranl.vip" ] &&
    out[configured]=false

for k in "${!out[@]}"; do
    v="${out[$k]}"
    echo "$k=$v" >>"$GITHUB_OUTPUT"
done

echo ::endgroup::

exit 0
