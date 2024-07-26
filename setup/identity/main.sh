#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Installing ssh keypair
ssh_dir="$RUNNER_TEMP/.__ssh"
[ ! -d "$ssh_dir" ] && mkdir -p "$ssh_dir"
echo "$SSH_KEY" >"$ssh_dir/id_ed25519"
echo "$SSH_KEY_PUB" >"$ssh_dir/id_ed25519.pub"
echo "${SSH_KEY_PUB##* } ${SSH_KEY_PUB% *}" >"$ssh_dir/allowed_signers"
chmod 0600 "$ssh_dir/id_ed25519"

echo - Configuring Git
git config --global user.name "GitHub Actions"
git config --global user.email "bot@kamaranl.vip"
git config --global user.signingkey "$ssh_dir/id_ed25519.pub"
git config --global gpg.ssh.allowedsignersfile "$ssh_dir/allowed_signers"
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global push.followtags true
git config --global push.default upstream

echo - Dumping config
sed 's/^/\t/' <(git config -l --show-scope | sort)

echo ::endgroup::

exit 0
