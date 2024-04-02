#!/bin/bash

echo ::group::Running "${GITHUB_ACTION_PATH##*_actions\/}" pre-checks...

[ "$(git config --global user.email)" != "bot@kamaranl.vip" ] &&
    echo is-configured=false >>"$GITHUB_OUTPUT"

echo ::endgroup::

exit 0
