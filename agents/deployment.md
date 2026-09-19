# NixOS Deployment

Deploy one NixOS host from this repository with `nh`:

```bash
nh os switch -H <host> --target-host <host> --elevation-strategy passwordless
```

For example:

```bash
nh os switch -H mimir --target-host mimir --elevation-strategy passwordless
```

`--target-host` is the remote SSH destination; this version of `nh` does not accept `--target`. The explicit `passwordless` elevation strategy is required for non-interactive remote deployment even when sudoers already grants the needed commands.

The NixOS baseline sudo policy must permit both phases used by `nh`:

1. `/nix/store/*-nixos-system-*/bin/switch-to-configuration` activates the generation.
2. `/run/current-system/sw/bin/nix build --no-link --profile /nix/var/nix/profiles/system /nix/store/*-nixos-system-*` makes it the boot default.

If activation succeeds but profile installation fails, the live generation and boot profile diverge. Do not retry the identical generation as reconciliation. Follow the failed-switch recovery guidance in `AGENTS.md`; after fixing the cause, deploy a genuinely new generation and verify:

```bash
ssh <host> 'readlink -f /run/current-system; readlink -f /nix/var/nix/profiles/system'
ssh <host> 'systemctl --failed --no-pager'
```

The two generation paths should match and no units should be failed.
