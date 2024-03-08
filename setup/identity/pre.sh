#!/bin/bash

[ "$(git config --global user.email)" != "bot@kamaranl.vip" ] &&
    echo "is-configured=false" >>"$GITHUB_OUTPUT"

exit 0
