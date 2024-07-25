#!/usr/bin/env bash

echo ::group::bash "$0"

mode=sln
out_dir="$INPUTS_OUT"

[ -z "$INPUTS_SLN" ] && {
    echo - Checking for solution file
    solution_files="$(find . -type f \
        -name '*.sln')"
}

IFS=$'\n' read -d '\n' -ra solutions <<<"${solution_files:-$INPUTS_SLN}" &&
    unset IFS

((${#solutions[@]} > 1)) && {
    echo -e ::error::More than one solution found:\\\n"$(printf \
        "  - %s\n" "${solutions[@]}")"\\\n\\\nPlease specify a solution file \
        using available input.
    echo ::endgroup::
    exit 1
}

((!${#solutions[@]})) && {
    mode=proj

    [ -z "$INPUTS_PROJ" ] && {
        echo - Checking for project files
        project_files="$(find . -type f \( \
            -name '*.csproj' -o \
            -name '*.fsproj' -o \
            -name '*.vcproj' -o \
            -name '*.vcxproj' \))"
    }

    IFS=$'\n' read -d '\n' -ra projects <<<"${project_files:-$INPUTS_PROJ}" &&
        unset IFS
}

[ ! -d "$out_dir" ] && mkdir -p "$out_dir"
out_dir="$(realpath "$out_dir")"

[ -z "$INPUTS_PARAMS" ] &&
    params=(
        --self-contained
        "-p:DebugType=none"
        "-p:DebugSymbol=false"
        "-p:Optimize=true"
        "-p:PublishSingleFile=true"
        "-p:PublishTrimmed=true"
    ) || IFS=$'\n' read -d '\n' -ra params <<<"$INPUTS_PARAMS" &&
    unset IFS

if [ "$mode" == sln ]; then
    params+=("-p:PublishDir=$out_dir")

    ! dotnet publish -c Release "${params[@]}" \
        "$solution" 2>&1 && {
        echo ::error::There was a problem compiling "$solution"
        echo ::endgroup::
        exit 1
    }
elif [ "$mode" == proj ]; then
    [ -z "$INPUTS_RIDS" ] &&
        rids=(
            linux-x64
            linux-arm
            linux-arm64
            osx-x64
            osx-arm64
            win-x64
            win-x86
            win-arm64
        ) || IFS=$'\n' read -d '\n' -ra rids <<<"$INPUTS_RIDS" &&
        unset IFS

    for project in "${projects[@]}"; do
        file="${project##*\/}"
        name="${file%%.*}"

        for rid in "${rids[@]}"; do
            [ "$rid" == win-* ] && {
                params+=("-p:PublishReadyToRun=true")
                name="${name^}"
            } || name="${name,,}"

            params+=(
                "-p:PublishDir=$out_dir/$rid"
                "-p:AssemblyName=$name"
            )

            ! dotnet publish -c Release -r "$rid" "${params[@]}" \
                "$project" 2>&1 && {
                echo ::error::There was a problem compiling "$project" for \
                    "$rid."
                echo ::endgroup::
                exit 1
            }
        done
    done
fi

echo "out-dir=$out_dir" >>"$GITHUB_OUTPUT"

echo ::endgroup::

exit 0
