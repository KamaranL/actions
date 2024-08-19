#!/usr/bin/env bash

echo ::group::bash "$0"

in_dir="$INPUTS_IN"

case $RUNNER_OS in
macOS) rid=osx ;;
Linux) rid=linux ;;
esac

echo - Searching for artifacts in "$in_dir"
IFS=$'\n' read -d '\n' -ra artifacts <<<"$(find "$in_dir/$rid"* \
    -type f)" &&
    unset IFS

((!${#artifacts[@]})) && {
    echo ::error::No artifacts found in "$in_dir".
    echo ::endgroup::
    exit 1
}

for artifact in "${artifacts[@]}"; do
    path="$(realpath "$artifact")"
    dir_path="${path%\/*}"
    dir_name="${dir_path##*\/}"

    echo - Signing "\"$path\""
    if [[ $dir_name == osx-* ]]; then
        codesign -fvs "$PFX_ID" --deep "$path" &>/dev/null

        echo - Verifying "\"$path\""
        sed 's/^/\t/' <(codesign -dvv "$path")
    else
        (
            cd "$dir_path"
            ssh-keygen -Y sign -f "$PFX_DIR/$PFX_ID"_key -n file "$path"
        )

        echo - Verifying "\"$path\""
        ssh-keygen -Y verify -f <(
            echo "$PFX_ID $(cat "$PFX_DIR/$PFX_ID".pub)"
        ) -n file -s "$path".sig -I "$PFX_ID" <"$path"
    fi

    (($?)) && {
        echo ::error::Failed to sign "\"$path\"" as "$PFX_ID".
        echo ::endgroup::
        exit 1
    }
done

echo ::endgroup::

exit 0
