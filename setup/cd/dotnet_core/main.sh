#!/bin/bash

echo ::group::Executing "${GITHUB_ACTION_PATH##*_actions\/}"

SLN="$(find . -type f -name '*.sln')"
ASSY_NAME="$(awk -F'= ' '/^Project(.*).*/{print $2}' "$SLN" |
    awk -F', ' '{gsub(/^"|"$/,"",$1); print $1}')"
DIST_TEMP="$RUNNER_TEMP/dotnet_core/dist"
PUB_TEMP="$RUNNER_TEMP/dotnet_core/publish"
[ ! -d "$DIST_TEMP" ] && mkdir -p "$DIST_TEMP"
[ ! -d "$PUB_TEMP" ] && mkdir -p "$PUB_TEMP"

[ ! -z "$INPUT_PARAMS" ] && {
    echo - Parsing input for override parameters
    INPUT_PARAMS=($INPUT_PARAMS)

    for PARAM in "${INPUT_PARAMS[@]}"; do
        PARAMS+=" -p:$PARAM"
        echo - Setting "$PARAM"
    done
} ||
    PARAMS=" -p:PublishSingleFile=true -p:PublishTrimmed=true \
-p:PublishDir=$PUB_TEMP"

[ ! -z "$INPUT_RIDS" ] && {
    echo - Parsing input for release identifiers
    RIDS=($INPUT_RIDS)
    RIDS=($(printf "%s\n" "${RIDS[@]}" | sort))
} ||
    RIDS=(win-x64)

for RID in "${RIDS[@]}"; do
    ARGS="publish -c Release -r $RID --self-contained$PARAMS"
    [ "$RID" == win-x64 ] &&
        ARGS+=" -p:PublishReadyToRun=true"

    echo - Compiling "$RID"
    ! dotnet $ARGS 2>&1 && {
        echo "::error::There was a problem compiling for $RID."
        exit 1
    }

    [ -f LICENSE.txt ] && cp LICENSE.txt "$PUB_TEMP/"
    [ -f README.md ] && cp README.md "$PUB_TEMP/"
    [ -d docs ] && cp -R docs "$PUB_TEMP/"

    echo - Packaging "$RID"
    [ "$RID" == win-x64 ] && (
        cd "$PUB_TEMP"
        zip -9r "$DIST_TEMP/$ASSY_NAME-$CI_VERSION-$RID.zip" .
    ) ||
        tar -czf "$DIST_TEMP/${ASSY_NAME,,}-$CI_VERSION-$RID.tgz" \
            -C "$PUB_TEMP" .

    echo - Cleaning "$PUB_TEMP ($RID)"
    rm -rf "$PUB_TEMP"/*
done

echo "dist=$DIST_TEMP" >>"$GITHUB_OUTPUT"

echo ::endgroup::

exit 0
