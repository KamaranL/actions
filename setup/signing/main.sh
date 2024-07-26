#!/usr/bin/env bash

echo ::group::bash "$0"

declare -A env

echo - Install pfx components
pfx_dir="$RUNNER_TEMP/.__pfx"
[ ! -d "$pfx_dir" ] && mkdir -p "$pfx_dir"

env[PFX_PASS]="$P12_PASS"
env[PFX_DIR]="$pfx_dir"
env[PFX_ID]='kamaranl@kamaranl.vip'
p12_cer="$pfx_dir/${env[PFX_ID]}.crt"
p12_key="$pfx_dir/${env[PFX_ID]}_key"
pfx="$pfx_dir/${env[PFX_ID]}.pfx"

echo "$P12_CER" >"$p12_cer"
echo "$P12_KEY" >"$p12_key"
chmod 0600 "$p12_key"

args=(pkcs12)
[ $RUNNER_OS != macOS ] && args+=(-legacy)

echo - Compiling pfx
openssl "${args[@]}" -export \
    -in "$p12_cer" \
    -inkey "$p12_key" \
    -out "$pfx" \
    -passout pass:"$P12_PASS" \
    -name KamaranL

echo - Validating pfx
! openssl "${args[@]}" -info -nodes \
    -in "$pfx" \
    -passin pass:"$P12_PASS" &>/dev/null && {
    echo -e ::error::\""$pfx"\" could not be validated. Please check \
        your key/cert and before proceeding.
    echo ::endgroup::
    exit 1
}

for k in "${!env[@]}"; do
    v="${env[$k]}"
    echo "$k=$v" >>"$GITHUB_ENV"
done

echo ::endgroup::

exit 0
