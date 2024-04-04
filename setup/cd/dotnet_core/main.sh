#!/bin/bash

declare -A env

echo ::group::bash "$0"

solution=($(find . -type f -name '*.sln'))
((${#solution[@]} > 1)) && {
    echo -e "::error::More than one solution found:\n$(
        printf "%s\n" "${solution[@]}"
    )"
    exit 1
}
! ((${#solution[@]})) && {
    echo ::error::No solution found
    exit 1
}
assembly="$(awk -F'= ' '/^Project(.*).*/{print $2}' "$solution" |
    awk -F', ' '{gsub(/^"|"$/,"",$1); print $1}')"
dotnet_dir="$RUNNER_TEMP/dotnet_core"
dist_dir="$dotnet_dir/dist"
pub_dir="$dotnet_dir/publish"
[ ! -d "$dist_dir" ] && mkdir -p "$dist_dir"
[ ! -d "$pub_dir" ] && mkdir -p "$pub_dir"

[ ! -z "$INPUTS_PARAMS" ] && {
    echo - Parsing input for override parameters
    inputs_params=($INPUTS_PARAMS)

    for p in "${inputs_params[@]}"; do
        params+=" -p:$p"
        echo - Setting "$p"
    done
} ||
    params=" -p:PublishSingleFile=true -p:PublishTrimmed=true \
-p:PublishDir=$pub_dir"

[ ! -z "$INPUTS_RIDS" ] && {
    echo - Parsing input for release identifiers
    inputs_rids=($INPUTS_RIDS)
    rids=($(printf "%s\n" "${inputs_rids[@]}" | sort))
} ||
    rids=(win-x64)

for r in "${rids[@]}"; do
    args="publish -c Release -r $r --self-contained$params"
    [ "$r" == win-x64 ] &&
        args+=" -p:PublishReadyToRun=true"

    echo - Compiling "$r"
    ! dotnet $args 2>&1 && {
        echo ::error::There was a problem compiling for "$r."
        exit 1
    }

    [ -f LICENSE.txt ] && cp LICENSE.txt "$pub_dir/"
    [ -f README.md ] && cp README.md "$pub_dir/"
    [ -d docs ] && cp -R docs "$pub_dir/"

    echo - Packaging "$r"
    [ "$r" == win-x64 ] && (
        cd "$pub_dir"
        zip -9r "$dist_dir/$assembly-$CI_VERSION-$r.zip" .
    ) ||
        tar -czf "$dist_dir/${assembly,,}-$CI_VERSION-$r.tgz" \
            -C "$pub_dir" .

    echo - Cleaning "$pub_dir ($r)"
    rm -rf "$pub_dir"/*
done

echo "dist=$dist_dir" >>"$GITHUB_OUTPUT"

echo ::endgroup::

exit 0
