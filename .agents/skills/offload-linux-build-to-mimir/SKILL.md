---
name: offload-linux-build-to-mimir
description: Work around a build failure in Determinate Nix's macOS Linux builder by offloading only the failing Linux derivation to the trusted Raspberry Pi mimir, copying its outputs back, and resuming locally. Use for builder-environment failures in tests or compilation; keep dependencies and the overall system build on the Mac.
---

# Offload one Linux build to mimir

## Scope and policy

The user permits offloading an individual derivation that fails in Determinate's Linux builder to `mimir`, **including compilation**, not just test execution. Do not ask for permission again for each ordinary targeted offload. Diagnose the failure first; do not assume every compilation error is a builder defect.

`mimir` is an underpowered Raspberry Pi. Keep the overall build and healthy dependency builds on the Mac. Never turn this workaround into `nh ... --build-host mimir`, a whole-system remote build, or a persistent change to builder configuration. If the selected derivation itself is likely to exceed the Pi's RAM, disk, or acceptable runtime, explain the evidence and agree on an alternative rather than starting a predictably unsuitable build.

Offload the **unchanged derivation**, with all its checks enabled. Do not fabricate successful outputs, disable tests, change package versions, alter sandbox policy, or rewrite a derivation to hide a failure.

This procedure only realises store outputs. It does not authorize switching, rebooting, or changing the Pi's system configuration. Resume activation only when it is part of the user's current request, following the repository's failed-switch recovery rules.

## 1. Identify the smallest failing build

- Inspect Git status and preserve existing work. Read the deployment notes at `../../../agents/deployment.md` relative to this skill directory.
- Find the actual failing `.drv` in the local build log, not the top-level system derivation that merely reports a dependency failure.
- Inspect `nix log` and `nix derivation show` for that path. Identify the failing operation, `system`, required system features, selected dependency outputs, and the build command or phases.
- Check that the derivation can execute on `mimir`. It is an `aarch64-linux` host; do not assume it can run `x86_64-linux`, Darwin builds, or specialised hardware-dependent tests. Check host capabilities when the derivation has additional requirements.
- Prefer one derivation at a time. A small explicit set of independently affected runners is reasonable when evidence supports offloading each. Do not send unrelated ancestors or dependency trees for rebuilding.
- If the failure looks like a genuine source/test regression rather than an environment problem, investigate instead of repeatedly trying different builders. An isolated native build can be a diagnostic comparison, but success on the Pi does not repair the Mac's builder.

## 2. Prepare already-built dependencies locally

Inspect the failing derivation's input derivations and the **specific outputs it consumes**. Resolve their store paths using `nix derivation show` or `nix-store --query --outputs`, then verify they are valid locally with `nix path-info`.

Do not blindly copy or build every output of an input derivation: it may expose unneeded debug, documentation, or other outputs. If a required output is missing, fetch or build it on the Mac first. If that dependency independently hits the same builder problem, treat it as a separate targeted offload.

Determine the paths from the current store and logs, never from historical hashes. JSON layouts of `nix derivation show` vary by Nix version; inspect the actual format before scripting against it. For dynamically resolved outputs, obtain their realised paths rather than guessing them.

## 3. Transfer the derivation and input closures

Use the user's working SSH connection, not the local daemon's remote-builder SSH identity. Verify connectivity with bounded, non-interactive SSH:

```sh
ssh -o BatchMode=yes -o ConnectTimeout=10 mimir 'uname -m; nix --version'
```

Copy the failing `.drv` and all selected, already-built dependency output paths using:

```text
TMPDIR=/tmp nix copy --no-check-sigs --to ssh-ng://mimir <failing.drv> <built-input-output-paths...>
```

All angle-bracket values in this document are explanatory placeholders. Resolve them to literal paths before making tool calls; do not pass placeholders or shell substitutions to terminal tools.

- Copying the `.drv` transfers its source/derivation closure, but **does not automatically transfer the compiled dependency outputs**. Include those explicitly. Nix copies their runtime closures automatically.
- `--no-check-sigs` permits our own unsigned build outputs exchanged with our trusted host over authenticated SSH. It requires the importing user to be trusted by Nix. Do not disable signature checking globally, use this flag with untrusted hosts, or grant new privileges to force a copy through.
- `TMPDIR=/tmp` avoids the observed macOS Unix-domain socket path-length failure when Zed gives Nix a long temporary path. It does not solve authentication errors.

## 4. Prove the Pi will build only the selected derivation

Run a dry run **over ordinary user SSH on mimir**:

```text
nix build --dry-run --no-link --builders '' --option substitute false '/nix/store/<failing>.drv^*'
```

Quote each installable containing `^*`. A bare `.drv` installable does not build its outputs.

Require the plan to list only the deliberately selected derivation(s), or nothing if the outputs already exist. The selected derivation may itself compile; that is allowed. **Any additional dependency build is a stop condition:** identify the missing dependency outputs, transfer or build them locally, and repeat the dry run. Do not proceed with an unexpectedly expanded remote build plan.

Keep `--builders ''`: `mimir` normally has distributed builders, and the workaround must run on the native Pi rather than silently delegate elsewhere. Disabling substitution makes the plan explicit; inputs should already be present.

## 5. Build with bounded resources

Run the same command on `mimir`, removing `--dry-run` and adding:

```text
-L --max-jobs 1 --cores 1
```

Keep `--no-link --builders '' --option substitute false`. These concurrency settings reduce load but are not hard CPU or memory limits for every build system.

Use a finite terminal timeout appropriate to the selected job. If it times out, report that and check whether a remote build is still running before retrying; do not assume terminating the SSH client cancelled all remote work. Let the user decide about a longer wait. If the build fails natively too, inspect its log rather than disabling checks or widening the remote build scope.

## 6. Copy genuine outputs back and verify reuse

After success, resolve the output paths from the actual derivation/store, for example using `nix-store --query --outputs`. Copy the realised outputs back:

```text
TMPDIR=/tmp nix copy --no-check-sigs --from ssh-ng://mimir <realised-output-paths...>
```

Then verify the original quoted `.drv^*` installable locally:

```text
nix build --no-link --offline --max-jobs 0 --builders '' '/nix/store/<failing>.drv^*'
```

This must succeed without executing a build or fetching anything. Finally dry-run the original local build and verify that the offloaded derivation is no longer scheduled. Resume that build on the Mac if requested, **without `--build-host mimir`**. Do not promise other remaining derivations will succeed; diagnose subsequent failures separately using this same bounded procedure.

No repository configuration change is normally necessary. Reuse lasts while these exact outputs remain available; changed inputs or garbage collection may require repeating the offload. This is a workaround, not a fix for the local builder.

## Report the result

State which derivation(s) were offloaded, whether compilation or only tests ran, their result, whether outputs were copied back and accepted locally, and whether the original build/deployment was resumed. Distinguish successful leaf builds from a successful complete deployment. Record genuinely new reusable findings in the deployment notes or this skill, without accumulating ephemeral store hashes.
