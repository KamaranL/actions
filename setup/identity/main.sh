#!/bin/bash

echo "::group::Configuring Git..."

# write ssh files
SSH_TEMP="$RUNNER_TEMP/.ssh"
[ ! -d "$SSH_TEMP" ] && mkdir -p "$SSH_TEMP"
echo "$SSH_ID" >"$SSH_TEMP/id_ed25519"
echo "$SSH_ID_PUB" >"$SSH_TEMP/id_ed25519.pub"
echo "${SSH_ID_PUB##* } ${SSH_ID_PUB% *}" >"$SSH_TEMP/allowed_signers"
chmod 0600 "$SSH_TEMP/id_ed25519"

# configure git
git config --global user.name "GitHub Actions"
git config --global user.email "bot@kamaranl.vip"
git config --global user.signingkey "$SSH_TEMP/id_ed25519.pub"
git config --global gpg.ssh.allowedsignersfile "$SSH_TEMP/allowed_signers"
git config --global gpg.format "ssh"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global push.followtags true
git config --global push.default "upstream"
sed 's/^/\t/' <(git config --list --global)

echo "::endgroup::"
