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

## Offloading builds by derivation name

The Python 3 helper is specific to Mimir: its flake output, Loki builder, and SSH host identity are hard-coded. Run it from the repository root and quote name globs so your shell does not expand them:

```bash
./scripts/offload-build '*nix-functional-tests*' --dry-run
./scripts/offload-build '*nix-functional-tests*'
```

With no patterns, it selects `'nix-*-tests-run*'` and `'nix-functional-tests-*'`. Supply one or more case-sensitive name globs to override those defaults. Use `--dry-run` to inspect the selection without building. It traverses the build-time derivation graph, so test runners and other build-only inputs are visible.

The helper builds each selected job's direct consumed dependency outputs using the normal configured builders, then offloads the selected job to Loki and verifies local reuse with networking and builds disabled. Selected jobs run in dependency order. It uses the multiuser Nix daemon and does not parse or alter builder configuration. It never resumes the whole build or activates anything; rerun your original `nh` command afterward.

The command-scoped builder is `ssh://loki aarch64-linux /etc/ssh/ssh_host_ed25519_key 1 2`, using the identity and speed factor configured for Loki in `modules/remote-builders.nix`, with one concurrent job. The daemon must be able to authenticate to Loki and verify its host key. Do not bypass host-key or store-signature verification or change private-key permissions.

Only `aarch64-linux` jobs are supported. No matches is an error. If dependency preparation encounters another builder failure, include that affected job in the patterns too.

Each Nix command has a fixed one-hour timeout. Remote builds upload inputs and dependency closures to Loki. If a timeout occurs, inspect remote work before retrying: killing the client does not guarantee cancellation. No checks are fabricated or disabled.

Test the helper without remote builds using:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s scripts -p 'test_*.py' -v
```

## Diagnosing Linux builds from macOS

`--target-host` selects the deployment destination, not the build machine. With Determinate's native Linux builder enabled on macOS, Linux derivations can execute in its local VM even when deploying to a native Linux host.

In the tested Determinate Nixd 3.22.5 builder, `/dev/ptmx` existed but `/dev/pts` and the `devpts` mount were absent. Determinate Nix 3.22.5's `ReadLine.TreatsEioAsEof` and `ReadLine.PartialLineBeforeEio` consequently failed at `posix_openpt`, before testing `readLine`. Both failed with and without the `enosys` wrapper. The identical full test binary, data, and syscall-blocking wrapper passed when run directly on `mimir` (798 passed, one skipped); this was not a sandboxed derivation build or a complete deployment validation.

Use `ssh://loki`, not nixbuild.net or `mimir`, for future targeted offloads. The user permits offloading **only an individual failing derivation**, including compilation when necessary, while keeping healthy dependencies and the overall build on the Mac. Follow the [offload-linux-build-to-nixbuild skill](../.agents/skills/offload-linux-build-to-nixbuild/SKILL.md): prepare dependencies locally, verify the bounded build plan, use the explicit `/etc/ssh/ssh_host_ed25519_key` client identity, and verify local reuse of the returned outputs. Keep the remote-builder override scoped to the failing derivation; do not move the whole system build to the server. The Pi results below are historical diagnostics, not the current offload procedure.

A full ARM Linux builder VM on the Mac is another option for normal PTY support. Integration must account for Determinate owning the Nix daemon configuration (`nix.enable = false`); nix-darwin's standard `nix.linux-builder` module requires `nix.enable = true`, so it is not a drop-in toggle here.

The test-only offload was subsequently verified for both `nix-util-tests-run` and `nix-util-tests-run-without-new-syscalls`: each sandboxed derivation passed on `mimir` (798 passed, one skipped, about ten seconds each). Their unchanged outputs were copied back to the Mac and accepted with builds and network access disabled. The local full-system dry run no longer scheduled either runner. This does not validate the remaining system build or deployment.

The PTY defect also affects nested-build tests in `nix-store-tests-run` and `nix-expr-tests-run`, reporting `opening pseudoterminal master: No such file or directory`. The unchanged store runner passed all 727 tests in a native sandboxed build on `mimir`, and its output was accepted locally with builds and network access disabled. The expression runner's three PTY-related failures passed natively, but the full runner then failed 129 later tests with `allocating arena using mmap: Cannot allocate memory`.

The expression-runner failure was traced to **virtual-address exhaustion, not physical RAM exhaustion**. In Determinate Nix 3.22.5, `SymbolTable` reserves a 1 GiB arena per evaluator using `MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE`; `ContiguousArena` has no destructor to `munmap` that reservation. Test fixtures repeatedly construct and destroy evaluators, retaining these mappings. `mimir`'s kernel has `CONFIG_ARM64_VA_BITS=39` (512 GiB address space) and 4 KiB pages. An unchanged trivial test repeated 600 times made 507 successful 1 GiB mappings, then 93 `ENOMEM` failures, with zero corresponding unmaps and only about 92 MiB peak RSS. Address/data limits and daemon cgroup memory limits were unlimited, with no daemon cgroup OOM events. More RAM or swap is not a remedy for this demonstrated address-space leak. Prefer an upstream lifetime-correct arena fix or a native Linux builder with a wider virtual address space; changing the Pi's kernel requires a separate explicit decision.

All 366 enabled expression tests passed in two fresh-process diagnostic batches (183 and 184 passes, with the initialization test repeated). Plain Google Test sharding is not sufficient: shard 2 omits `DerivedPathExpressionTest.force_init` and aborts because `nix::initNix()` has not run. Explicitly including that initialization test in the second batch resolves this diagnostic ordering problem. These direct test runs do not realise the original single-process derivation and must not be used to fabricate its output.

The unchanged single-process expression runner subsequently passed all 366 tests on nixbuild.net, avoiding the Pi's virtual-address limit. Its output was accepted on the Mac with `nix build --no-link --offline --max-jobs 0 --builders '' '<runner.drv>^*'`. For a targeted aarch64-linux offload, the working explicit builder specification is `--max-jobs 0 --builders 'ssh://eu.nixbuild.net aarch64-linux /etc/ssh/ssh_host_ed25519_key 1 1'`; authentication with the user's `id_ed25519` was rejected, while the explicit host identity succeeded. Keep this override scoped to the individual affected derivation, not the entire system build, and never document private key contents or signed log URLs.

The unchanged Determinate Nix 3.22.5 functional suite on nixbuild.net passed 214 tests, skipped eight, and failed only `ps`. Its log reports `opening file "/proc/<pid>/task/<pid>/children": No such file or directory`; `nix ps` lists the builder shell but cannot discover the background `sleep 600`, failing `ps.sh:40`. This is a separate process-discovery/procfs compatibility failure, not the Mac's PTY defect or the Pi's address-space exhaustion. The log alone does not establish whether the server omits that procfs interface or Nix mishandles process namespaces; do not assume changing Nix versions fixes it or silently disable the check.

A diagnostic attempt to create `/dev/pts` in an ordinary local build failed with permission denied: the guest runs the derivation as `nixbld`, not root. A simple package `preCheck` mount is therefore not a fix; repairing the mount belongs in the builder's privileged setup.


Zed's macOS terminal can give Nix a temporary directory long enough to exceed the Unix-domain socket path limit for its SSH master connection. If `nix copy` reports `unix_listener: path ... too long for Unix domain socket`, prefix the command with `TMPDIR=/tmp`. This fixes the observed client-side socket-path issue, not arbitrary SSH authentication or daemon-side remote-builder failures.
