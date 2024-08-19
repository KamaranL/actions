#!/usr/bin/env bash

echo ::group::bash "$0"

certs=(
    "$PFX_DIR/ca.crt"
    "$PFX_DIR/int-ca.crt"
)

pfx="$PFX_DIR/$PFX_ID"

case $RUNNER_OS in
macOS)
    security unlock-keychain ~/Library/Keychains/login.keychain -p ""

    echo - Adding Certificate Authorities to keychain
    for cert in "${certs[@]}"; do
        ! security import "$cert" -k ~/Library/Keychains/login.keychain -A && {
            echo ::error::Failed to import \""$cert"\" into login keychain.
            echo ::endgroup::
            exit 1
        }
    done

    echo - Adding code signing cert to keychain
    ! security import "$pfx.pfx" \
        -k ~/Library/Keychains/login.keychain \
        -P "$PFX_PASS" \
        -T /usr/bin/codesign && {
        echo ::error::Failed to import \""$pfx".pfx\" into login keychain.
        echo ::endgroup::
        exit 1
    }
    ;;
Linux)
    echo - Converting cert+key to OpenSSH format
    ssh-keygen -f <(openssl x509 -pubkey -noout -in "$pfx".crt) -i \
        -m PKCS8 >"$pfx".pub
    ssh-keygen -p -N "" -f "$pfx"_key
    ;;
esac

echo ::endgroup::

exit 0
