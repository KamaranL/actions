#!/usr/bin/env bash

echo ::group::bash "$0"

required_vars=(
    PFX_DIR
    PFX_ID
)

echo - Checking required variables
for req in "${required_vars[@]}"; do
    declare -n var="$req"

    echo - Checking "$req"
    [ -z "$var" ] && {
        echo ::error::"$req" not set.
        echo ::endgroup::
        exit 1
    }
done

echo ::endgroup::

exit 0
