#!/usr/bin/env bash

echo ::group::bash "$0"

declare -A out env

pfx_dir="$RUNNER_TEMP/.__pfx"
[ ! -d "$pfx_dir" ] && mkdir -p "$pfx_dir"
out[cert]="$pfx_dir/kamaranl@kamaranl.vip.crt"
out[key]="$pfx_dir/kamaranl@kamaranl.vip_key"
out[pfx]="$pfx_dir/kamaranl@kamaranl.vip.pfx"

echo - Install pfx components
echo "$P12_CER" >"${out[cert]}"
echo "$P12_KEY" >"${out[key]}"
chmod 0600 "${out[key]}"

echo - Compiling pfx
openssl pkcs12 -legacy -export \
    -in "${out[cert]}" \
    -inkey "${out[key]}" \
    -out "${out[pfx]}" \
    -passout pass:"$P12_PASS" \
    -name KamaranL

echo - Validating pfx
! openssl -legacy -info -nodes \
    -in "${out[pfx]}" \
    -passin pass:"$P12_PASS" &>/dev/null && {
    echo -e ::error::\""${out[pfx]}"\" could not be validated.\\\n\\\nPlease \
        check your key/cert and before proceeding.
    echo ::endgroup::
    exit 1
}

for k in "${!out[@]}"; do
    v="${out[$k]}"
    echo "$k=$v" >>"$GITHUB_OUTPUT"
done

echo ::endgroup::

exit 0
