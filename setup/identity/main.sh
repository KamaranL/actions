#!/bin/bash

echo ::group::Executing "${GITHUB_ACTION_PATH##*_actions\/}"

echo - Writing ssh keypair
ssh_temp="$RUNNER_TEMP/.ssh"
[ ! -d "$ssh_temp" ] && mkdir -p "$ssh_temp"
echo "$SSH_ID" >"$ssh_temp/id_ed25519"
echo "$SSH_ID_PUB" >"$ssh_temp/id_ed25519.pub"
echo "${SSH_ID_PUB##* } ${SSH_ID_PUB% *}" >"$ssh_temp/allowed_signers"
chmod 0600 "$ssh_temp/id_ed25519"

echo - Configuring Git
git config --global user.name "GitHub Actions"
git config --global user.email "bot@kamaranl.vip"
git config --global user.signingkey "$ssh_temp/id_ed25519.pub"
git config --global gpg.ssh.allowedsignersfile "$ssh_temp/allowed_signers"
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global push.followtags true
git config --global push.default upstream

echo - Configured as:
sed 's/^/\t/' <(git config --list --global)

echo ::endgroup::

exit 0
