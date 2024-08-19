#!/usr/bin/env bash

echo ::group::bash "$0"

declare -A env

echo - Installing pfx components
pfx_dir="$RUNNER_TEMP/.__pfx"
[ ! -d "$pfx_dir" ] && mkdir -p "$pfx_dir"

env[PFX_PASS]="$PASS"
env[PFX_DIR]="$pfx_dir"
env[PFX_ID]='kamaranl@kamaranl.vip'
pfx="$pfx_dir/${env[PFX_ID]}"

echo "$ROOT_CA" >"$pfx_dir/ca.crt"
echo "$INT_CA" >"$pfx_dir/int-ca.crt"
echo "$CER" >"$pfx".crt
echo "$KEY" >"$pfx"_key
chmod 0600 "$pfx"_key

args=(pkcs12)
[ $RUNNER_OS != macOS ] && args+=(-legacy)

echo - Compiling pfx
openssl "${args[@]}" -export \
    -in "$pfx".crt \
    -inkey "$pfx"_key \
    -out "$pfx".pfx \
    -passout pass:"$PASS" \
    -name KamaranL

echo - Validating pfx
! openssl "${args[@]}" -info -nodes \
    -in "$pfx".pfx \
    -passin pass:"$PASS" &>/dev/null && {
    echo ::error::\""$pfx".pfx\" could not be validated. Please check \
        your key/cert and before proceeding.
    echo ::endgroup::
    exit 1
} || echo Valid.

case $RUNNER_OS in
Linux) env[RID]=linux ;;
macOS) env[RID]=osx ;;
Windows) env[RID]=win ;;
esac

for k in "${!env[@]}"; do
    v="${env[$k]}"
    echo "$k=$v" >>"$GITHUB_ENV"
done

echo ::endgroup::

exit 0
