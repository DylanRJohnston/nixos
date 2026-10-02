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

## Diagnosing Linux builds from macOS

`--target-host` selects the deployment destination, not the build machine. With Determinate's native Linux builder enabled on macOS, Linux derivations can execute in its local VM even when deploying to a native Linux host.

In the tested Determinate Nixd 3.22.5 builder, `/dev/ptmx` existed but `/dev/pts` and the `devpts` mount were absent. Determinate Nix 3.22.5's `ReadLine.TreatsEioAsEof` and `ReadLine.PartialLineBeforeEio` consequently failed at `posix_openpt`, before testing `readLine`. Both failed with and without the `enosys` wrapper. The identical full test binary, data, and syscall-blocking wrapper passed when run directly on `mimir` (798 passed, one skipped); this was not a sandboxed derivation build or a complete deployment validation.

`mimir` is an underpowered Raspberry Pi: do not move the entire build there as the default workaround. The user permits offloading **only an individual failing derivation**, including compilation when necessary, while keeping healthy dependencies and the overall build on the Mac. Use the [offload-linux-build-to-mimir skill](../.agents/skills/offload-linux-build-to-mimir/SKILL.md) to transfer already-built inputs, verify a bounded remote build plan, realise the unchanged derivation on the Pi, and copy its outputs back. Do not substitute `--build-host mimir` for this targeted procedure.

A full ARM Linux builder VM on the Mac is another option for normal PTY support. Integration must account for Determinate owning the Nix daemon configuration (`nix.enable = false`); nix-darwin's standard `nix.linux-builder` module requires `nix.enable = true`, so it is not a drop-in toggle here.

The test-only offload was subsequently verified for both `nix-util-tests-run` and `nix-util-tests-run-without-new-syscalls`: each sandboxed derivation passed on `mimir` (798 passed, one skipped, about ten seconds each). Their unchanged outputs were copied back to the Mac and accepted with builds and network access disabled. The local full-system dry run no longer scheduled either runner. This does not validate the remaining system build or deployment.

A diagnostic attempt to create `/dev/pts` in an ordinary local build failed with permission denied: the guest runs the derivation as `nixbld`, not root. A simple package `preCheck` mount is therefore not a fix; repairing the mount belongs in the builder's privileged setup.


Zed's macOS terminal can give Nix a temporary directory long enough to exceed the Unix-domain socket path limit for its SSH master connection. If `nix copy` reports `unix_listener: path ... too long for Unix domain socket`, prefix the command with `TMPDIR=/tmp`. This fixes the observed client-side socket-path issue, not arbitrary SSH authentication or daemon-side remote-builder failures.
