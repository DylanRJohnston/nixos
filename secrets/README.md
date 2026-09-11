# Secrets

Secrets are encrypted with [SOPS](https://getsops.io/) and decrypted on each host by
[sops-nix](https://github.com/Mic92/sops-nix). The repository's `.sops.yaml` maps each
host directory to two distinct kinds of recipients derived from SSH Ed25519 public
keys:

- Administrator **user keys** allow `dylanj` to edit secrets from `odin` or `loki`.
- A target **host key** allows `sops-nix` to decrypt secrets on `mimir` during
  activation.

On each administrator machine, make its matching user SSH private key available to
SOPS as an age identity:

```sh
mkdir -p ~/.config/sops/age
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 >> ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Then create or edit a secret for `mimir` with:

```sh
sops secrets/mimir/<name>.yaml
```

Only commit the encrypted file. The `dylanj@odin` and `dylanj@loki` user keys can
edit it, while `mimir` decrypts it during activation with its separate
`/etc/ssh/ssh_host_ed25519_key` host key. Never commit private keys,
`~/.config/sops/age/keys.txt`, or plaintext secret material.

After changing a host recipient in `.sops.yaml`, rotate existing files with:

```sh
sops updatekeys secrets/mimir/<name>.yaml
```
