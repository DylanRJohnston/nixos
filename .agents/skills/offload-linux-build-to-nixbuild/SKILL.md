---
name: offload-linux-build-to-nixbuild
description: Work around environment failures in Determinate Nix's macOS Linux builder by offloading only the failing Linux derivation to eu.nixbuild.net. Use for tests or compilation; keep healthy dependencies and the overall system build on the Mac.
---

# Offload one Linux build to nixbuild.net

## Scope and policy

The user permits targeted offloading of individual failing Linux derivations to `ssh://eu.nixbuild.net`, including compilation, without asking again for each ordinary offload. Use this server instead of `mimir`. Diagnose first: genuine source or test regressions should not be treated as builder defects.

Keep healthy dependency builds and the overall system build on the Mac's configured builders. Do not move the entire system build to the server or persistently change builder configuration. Offload the unchanged derivation with all checks enabled: never disable tests, fabricate outputs, change versions, or alter sandbox policy to conceal a failure.

This remote service receives the derivation, source inputs, and dependency closures and may incur account charges. Do not upload secrets or unrelated private data. Ask before unusually expensive jobs or jobs with unclear data-sharing implications. This procedure authorizes no activation, reboot, or host configuration changes.

## Name-based helper

For Mimir, prefer the repository's small helper with its host, server, and identity hard-coded:

```sh
./scripts/offload-build '*nix-functional-tests*' --dry-run
./scripts/offload-build '*nix-functional-tests*'
```

Choose quoted name globs for the affected jobs and inspect the dry-run selection. With no patterns, the helper selects Nix unit-test runners and functional tests. It prepares direct dependencies through normal configured builders, offloads selected jobs in dependency order, and verifies local reuse through the multiuser daemon. It does not resume or activate the enclosing build. See `agents/deployment.md` for usage and testing. Keep it specific to Mimir's current problem; do not add generic builder configuration or subgraph machinery without a concrete requirement. Use the manual procedure below for other cases.

## 1. Identify the smallest failing build

- Inspect Git status and preserve existing work. Read `../../../agents/deployment.md` relative to this skill directory.
- Find the actual failing `.drv`, not the system derivation reporting a dependency failure.
- Inspect `nix log` and `nix derivation show`: identify the failing operation, target system, required system features, consumed dependency outputs, and build phases.
- Prefer one derivation at a time. Do not include unrelated ancestors or dependency trees.
- The verified recipe below is for `aarch64-linux`. Verify service support before selecting another architecture or additional features; do not invent supported features.

## 2. Prepare dependencies locally and check the plan

Resolve the specific dependency outputs consumed by the failing derivation and verify them with `nix path-info`. Fetch or build missing healthy dependencies locally first. Do not blindly build all outputs, including unused debug or documentation outputs. Treat independently failing dependencies as separate targeted offloads.

Resolve current store paths from the actual logs/store, never historical hashes. Inspect the current JSON layout of `nix derivation show` before scripting against it.

Run a local dry run for the selected installable:

```text
nix build --dry-run --no-link --max-jobs 0 --builders 'ssh://eu.nixbuild.net aarch64-linux /etc/ssh/ssh_host_ed25519_key 1 1' '/nix/store/<failing>.drv^*'
```

Angle-bracket values are explanatory placeholders: resolve them to literal paths before tool calls. Quote installables containing `^*`; a bare `.drv` does not build its outputs.

Require the plan to list only the deliberately selected derivation(s), or nothing if already realised. Additional dependency builds are a stop condition: prepare those dependencies locally and repeat the dry run. A dry run verifies the local plan, not remote authentication or hardware capabilities.

## 3. Build using the explicit daemon identity

```text
nix build --no-link -L --max-jobs 0 --builders 'ssh://eu.nixbuild.net aarch64-linux /etc/ssh/ssh_host_ed25519_key 1 1' '/nix/store/<failing>.drv^*'
```

This command-scoped override sends the selected build to nixbuild.net and returns its outputs to the local store through Nix's remote-build protocol. No manual `ssh-ng` copy or remote shell execution is needed. `--max-jobs 0` prevents local fallback during the offload; the builder's job count is one, not a hard server CPU/memory limit.

Use `/etc/ssh/ssh_host_ed25519_key` explicitly: it is the verified registered client identity. The user's `id_ed25519` was rejected, and the daemon does not automatically use the user's SSH agent or select the host key. Never read, copy, or document private key contents. Client authentication and server host-key verification are separate: do not bypass host-key verification; ask the user to verify an unknown server key. Do not grant privileges or alter daemon configuration to force authentication.

Use a finite timeout appropriate to the job. On timeout, report it and inspect whether work continues before retrying; terminating the client does not prove remote work stopped. Let the user decide about a longer wait. If the unchanged build also fails remotely, inspect its log rather than disabling checks or widening the scope.

## 4. Verify local reuse and resume

```text
nix build --no-link --offline --max-jobs 0 --builders '' '/nix/store/<failing>.drv^*'
```

This must succeed without a build or fetch. Dry-run the original local build to verify the offloaded derivation is no longer scheduled, then resume it if requested, without the nixbuild.net override or a whole-system `--build-host` option. Diagnose subsequent failures individually. Activate only when explicitly part of the user's task, following failed-switch recovery guidance.

No repository configuration change is normally necessary. Changed inputs or garbage collection may require another offload. This is a workaround, not a repair of the local Linux builder.

## Report the result

State which derivations were offloaded, whether compilation or only tests ran, their results, whether outputs were accepted locally, and whether the original build resumed. Distinguish successful leaf builds from a completed system build or deployment. Record only durable findings; omit ephemeral store hashes, private keys, and signed log URLs.
