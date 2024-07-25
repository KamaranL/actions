#!/usr/bin/env bash

echo ::group::bash "$0"

function get_name
{

    is_win="$([ "$1" == --win ] && echo true || echo false)"

    if [ -z "$INPUTS_NAME" ]; then
        name=
        IFS='-' read -ra parts <<<"${GITHUB_REPOSITORY##*\/}" && unset IFS
        for part in "${parts[@]}"; do
            $is_win &&
                name+="${part^}" ||
                name+="$part"
        done
    else
        name="$INPUTS_NAME"
        ! $is_win && name="${name,,}"
    fi

    echo "$name"
}

function add_files
{
    [ -z "$INPUTS_ADD_FILES" ] && return

    local file

    IFS=$'\n' read -d '\n' -ra files <<<"$INPUTS_ADD_FILES" && unset IFS

    for file in "${files[@]}"; do
        [ -f "$file" ] && {
            file="$(realpath $file)"
            cp -vr $file "$1"
        }
    done
}

in_dir="$INPUTS_IN"
out_dir="$INPUTS_OUT"

echo - Searching for build artifacts in "$in_dir"
IFS=$'\n' read -d '\n' -ra artifacts <<<"$(find "$in_dir/"* \
    -type f)" &&
    unset IFS

((!${#artifacts[@]})) && {
    echo ::error::No artifacts found in "$in_dir".
    echo ::endgroup::
    exit 1
}

[ ! -d "$out_dir" ] && mkdir -p "$out_dir"
out_dir="$(realpath "$out_dir")"

for artifact in "${artifacts[@]}"; do
    path="$(realpath "$artifact")"
    dir_path="${path%\/*}"
    dir_name="${dir_path##*\/}"

    if [[ $dir_name == win-* ]]; then
        out="$out_dir/$(get_name --win)_${CI_TAG}_${dir_name}.zip"
        [ -f "$out" ] && continue

        add_files "$dir_path"
        (
            cd "$dir_path"
            zip -v9r "$out" . 2>&1
        )
    else
        out="$out_dir/$(get_name)_${CI_TAG}_${dir_name}.tgz"
        [ -f "$out" ] && continue

        add_files "$dir_path"
        tar -vczf "$out" -C "$dir_path" .
    fi

    (($?)) && {
        echo ::error::There was a problem compressing "$dir_name".
        echo ::endgroup::
        exit 1
    } || echo - Compressed "$dir_name (${out##*\/})"
done

echo "out-dir=$out_dir" >>"$GITHUB_OUTPUT"

echo ::endgroup::

exit 0
