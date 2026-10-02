# den v0.19.0 migration handoff

## Goal and user constraints

Move this repository from `github:dylanrjohnston/den/dylan.johnston/strict-mode` back to upstream `github:denful/den/v0.19.0`, preserving transitive host-role configuration for OS users and Home Manager. User explicitly requested regression tests before switching, and later a minimal reproducer for a failing `nh darwin build`.

Migration validation is complete: focused suites, repository CI (81/81 tests), and a non-activating asgard Darwin build passed. No configuration has been deployed, no commits created, and no branches created. Read `AGENTS.md` and `agents/aspect-system.md` before continuing. Operating documentation now describes upstream den 0.19 APIs; see the documentation update below. This does not establish final migration validation or build completion.

## Working tree

The tree was initially clean. Current changes are migration work, except that `modules/bootloader.nix` was updated between interrupted turns to use `providerType` and add tests; preserve those changes. Inspect Git status/diffs before editing. `modules/host-aspects-test.nix` is newly created and was staged early so Git-backed flakes see it; later changes are unstaged. Preserve staging. This handoff is newly created and not staged.

The disposable `migration-tests.log` was removed after validation. The new ADR was staged so Git-backed flake evaluation could see it; pre-existing staging was preserved.

## Current architecture

### Input and namespace

- `flake.nix` now selects `github:denful/den/v0.19.0`.
- `flake.lock` pins den revision `37eb88ce28a9e42d5b367b967a9097030ff4f665` (tag v0.19.0). Only den was updated.
- `modules/namespace.nix` retains strict mode, replaces importing `flakeOutputs.all` directly with `inputs.den.flakeOutputs.all.includes`, removes `den.ctx`, and explicitly declares aspect class options (`nixos`, `darwin`, `os`, `user`, `homeManager`) as deferred modules, as the fork's strict class declarations are not supplied upstream.
- Upstream namespace import strips `_` and `__functor`, but not its generated provides-navigation aliases. Strict mode rejected `__providesForwarded`, then forwarded child keys such as `bluetooth`, while evaluating synthetic consumers. The current namespace import pre-processes exported top-level aspect values to remove the names listed in `value.__providesForwarded` and the marker itself before passing them to upstream's namespace importer. This got the harness evaluating. Preserve this strict namespace adapter; do not simply disable strict mode. The mesh key failures described historically below were subsequently traced to user key assignment, not namespace round-trip behavior.

### Host selection and projection

All host selection declarations and underlying test-host declarations now use:

```nix
aspect.includes = [ arc.base arc.development /* ... */ ];
```

Upstream `host.aspects` is a read-only resolved-tree introspection output, not a writable input. Do not restore the old custom option under that name.

The old custom `modules/host-aspects.nix` forwarded each host-selected aspect into:

- `host.class` and `os` at the host root;
- `user` into `users.users.<userName>`;
- `homeManager` into `home-manager.users.<userName>`.

Its replacement is a shared/exported integration module:

```nix
let
  module = { lib, den, ... }: {
    den.schema.user = {
      includes = [ den.batteries.host-aspects ];
      config.classes = lib.mkDefault [ "user" "homeManager" ];
    };
  };
in {
  imports = [ module ];
  flake.flakeModule = module;
}
```

**Critical tested finding:** registering this through `arc.schema.user.includes` did NOT activate the projection hook. `arc.schema.user` is transported as a deferred module, which preserves instance-module configuration such as classes but does not deliver this schema-level projection hook in the needed way. Register directly under `den.schema.user.includes` and export the module so synthetic consumers use the same integration.

`user.classes` is upstream's environment-selection metadata, not a claim that OS user options and HM options share a module evaluation. The native home integration separately forwards `user` and `homeManager` to their respective destinations. User questioned this; we checked upstream source/docs and clarified it rather than changing classes.

### Preserve the platform-specific Home Manager shim

The user explicitly clarified why `modules/home-manager.nix` has this:

```nix
homeManager = { osConfig, ... }: {
  imports = [ osConfig.homeManager ];
  home.stateVersion = "26.05";
  manual.manpages.enable = false;
};
```

**Keep this shim.** It supports all of:

```nix
aspect.homeManager          # direct den projection
aspect.nixos.homeManager   # host deferred module imported via osConfig
aspect.darwin.homeManager  # host deferred module imported via osConfig
aspect.os.homeManager      # same host shim, both platforms
```

The `os` class declares `options.homeManager` as a deferred module and configures `home-manager.useGlobalPkgs/useUserPackages`. The `homeManager` class imports that deferred module into every user's HM evaluation, retaining HM's own `config` and `pkgs`.

The explicit imports of `inputs.home-manager.nixosModules.home-manager` and `.darwinModules.home-manager` were initially removed as redundant with native integration, but have now been restored: `arc.base` must also evaluate on hosts with no users, where upstream's automatic HM module detection does not activate. Without these imports, base's `home-manager.useGlobalPkgs` config referred to a missing option.

### Other compatibility changes already made

- Five deprecated `den.lib.perHost` wrappers were replaced with plain aspect context functions in `modules/bootloader.nix`, `modules/nh.nix`, `modules/public-ingress.nix`, and the two Calibre modules. Once projection actually ran, deprecated wrappers failed with a missing `host` argument while being inspected/resolved. Existing parentheses remain around several plain lambdas; formatting cleanup is pending. Some outer `den` arguments may now be unused; don't remove ones still used elsewhere in their files without checking.
- `modules/zsh.nix` default-shell now uses `lib.mkDefault pkgs.zsh`. Upstream entity fan-out began applying this alongside `den.batteries.user-shell` for `dylanj`, causing a unique shell-option conflict. Tests cover an explicit bash shell overriding the zsh default on both platforms.
- Explicit `host.aspect.includes` replaces the default named `den.aspects.<host>` lookup. `hosts/loki/loki.nix` and `hosts/mimir/mimir.nix` now explicitly include `den.aspects.loki` / `den.aspects.mimir` so their existing hardware configurations remain applied. Loki previously lost its root filesystem. The same issue remains in the mesh service test, below.
- `modules/unit-test.nix` supplies `den.schema.host.config.flake = lib.mkDefault "/tmp/arc-unit-test"` to synthetic hosts. Upstream forces schema metadata earlier; the production `host.flake` default accesses `host.primaryUser.home`, which is invalid for test hosts with no users or multiple users and no primary. Tests can override this default. Projection test fixtures also set `/tmp/projection` explicitly.
- `modules/ssh.nix` disabled tests now expect missing `home.stateVersion`, rather than missing `home-manager`. Upstream imports HM automatically for users whose classes contain `homeManager` even without base. Base omission still omits HM initialization/settings. This is an intentional observable migration difference; do not hide it by universally assigning stateVersion.
- `modules/bootloader.nix` uses `den.lib.aspects.types.providerType` instead of `aspectType` for the aspect-valued host `boot` option. That change was already present when this session resumed, together with invalid-value, inline-aspect, and undeclared-option tests. Only its `perHost` wrapper was changed by this resumed session.

## Regression suite and evidence

`modules/host-aspects-test.nix` defines `flake.tests.host-aspects` through `unitTest` synthetic hosts. All leaf names have `test-` prefixes.

Initially **13/13 tests passed against the fork before changing den**, and the baseline CI passed **72/72** at that point. The suite now has **19 tests**:

For each of NixOS and Darwin:

1. Default zsh shell versus explicit upstream user-shell override.
2. Minimal HM reproducer: a host includes HM config and the final user's HM stateVersion/file text must be present (also checks selected classes).
3. Host with no users still receives OS content.
4. Omitted host-class content stays absent.
5. Omitted OS-class content stays absent.
6. Omitted user-class content stays at platform defaults.
7. Omitted HM-class file stays absent (expected evaluation error).
8. Platform-specific HM shim: `os.homeManager`, `${class}.homeManager` (a function reading HM `config.home.username`), and direct `homeManager` combine, with stateVersion supplied by the real project HM sub-aspect.
9. Transitive nested includes apply host, OS, user, and HM content; two users including a renamed `userName` get distinct host/user context values.

Plus one test checks the same username on two different hosts retains distinct HM context.

No diamond/dedup invariant was added: an early diamond probe revealed the old fork duplicates lines, so the established baseline tests use a linear nested chain rather than inventing a behavior-preserving requirement that was not true on the fork.

### Commands actually run and latest outcomes

- Final `nix-unit --flake '.#tests.host-aspects'`: **19/19 passed**, after restoration of HM platform imports.
- Final `nix-unit --flake '.#tests.mesh'`: **3/3 passed**.
- Final `nix-unit --flake '.#tests.bootloader'`: **5/5 passed**.
- Final `./.github/workflows/CI.sh`: **passed**, including all four hosts/all systems and **81/81 tests**.
- `nh darwin build . --hostname asgard --no-nom`: **passed** without activation, producing `/nix/store/56y4iwms8lhsdb5nd8lhzcxjhgx0amaf-darwin-system-26.11.4cff07d`.
- Touched Nix files were formatted with `nixfmt`.
- `nix eval --raw .#darwinConfigurations.asgard.system.drvPath`: **passed**, yielding a Darwin system derivation after fixing the shell conflict. This was evaluation only, not a build/deploy.
- Historical intermediate CI/unit runs reached 73/81 and then 77/81 before the final fixes below.

The final Darwin build passed; no switch or deployment was performed. Common command warnings about unknown Nix settings/experimental features are from the nix-unit executable/environment; they did not prevent tests running. `den.lib.take.upTo` still emits a deprecation warning from `modules/lib.nix`.

## Failures from the last recorded full-suite run

These describe the historical 77/81 run. All four failures are now resolved; the final full suite passed 81/81.

### 1. `bootloader.test-invalid-value`

Expected:

```text
not of type.*aspect or function returning aspect
```

Actual:

```text
cannot coerce an integer to a string: 42
```

The trace confirmed upstream reaches module loading before the old provider-type diagnostic. The negative test now asserts the verified integer-coercion error, preserving invalid-value rejection and leaving valid boot behavior unchanged.

### 2–3. `mesh.test-cross-host-user-keys` and `mesh.test-cross-host-host-keys`

In `modules/mesh/keys.nix`, the deferred/exported module is intended to compute keys from `den.hosts` **at the importing site**. Actual final authorized-key lists are empty:

```nix
{ boba = [ ]; kiki = [ ]; }
```

Expected values include `boba-apple`, `boba-pear`, `kiki-orange`, `kiki-pear`, and for the host-key variant `orange-host-key`.

**Resolved root cause:** upstream `configOf` strips top-level `key` as module metadata. Assignments such as `users.boba.key` therefore did not populate the declared user key option. Use `users.boba.config.key` (and the equivalent for every user) instead. Focused mesh key tests pass with this assignment change only, preserving the expected cross-host lists. All four production hosts were migrated to `users.dylanj.config.key` too. The previous namespace-closure/provenance hypothesis was unproven and is not the explanation for these failures; no mesh key-generation rewrite is needed. The final focused mesh suite and full CI reran and passed these tests.

Useful commands:

```sh
nix eval --json '.#tests.mesh.test-cross-host-user-keys.expr'
nix eval --json '.#tests.mesh.test-cross-host-user-keys.expected'
```

### 4. `mesh.test-service`

In `modules/mesh/services.nix`, synthetic host `igloo.aspect.includes` selects base and mesh services, but endpoint registrations still live under `den.aspects.igloo.nixos.services.tailscale-serve`. Explicit aspect replacement means this named aspect is no longer automatically selected.

Actual script expression: `[]`.

Expected two tailscale serve lines for `bass` and `hass`.

Resolved by explicitly including `den.aspects.igloo` in the synthetic host's aspect list and requesting `den` as a test module argument, analogous to Loki/Mimir hardware selection. The unchanged expected service commands now pass.

## Next steps

Implementation, formatting, focused tests, CI, non-activating Darwin build, and temporary-log cleanup are complete. Review the migration diff before committing or deploying; neither was requested. Preserve existing staged work. Operating documentation and ADR 0003 are updated below.

## Documentation update

`AGENTS.md` and `agents/aspect-system.md` now document upstream den 0.19 host `aspect.includes`, read-only `host.aspects`, plain aspect context functions, the direct exported schema projection hook, separate native OS-user/HM evaluations, the preserved OS HM shim and no-user platform imports, explicit named host-aspect inclusion, and mandatory `users.<name>.config.key` assignment.

[ADR 0003](../docs/architecture/decisions/0003-adopt-upstream-den-host-projection.md) records the accepted cross-cutting integration decision, alternatives, and consequences; the ADR index includes it. ADRs 0001 and 0002 were not rewritten. Architectural acceptance is separate from migration completion.

Final focused suites, repository CI, and the non-activating Darwin build passed as recorded above. No deployment occurred. The confirmed key-assignment and projection lessons are captured in operating docs and ADR 0003; no further speculative learning update is warranted.

## Upstream references used (v0.19.0)

Use GitHub fetch rather than browsing outside the project:

- `https://github.com/denful/den/releases/tag/v0.19.0`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/modules/aspects/batteries/host-aspects.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/modules/aspects/batteries/home-manager.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/nix/lib/home-env.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/docs/src/content/docs/guides/home-manager.mdx`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/nix/lib/namespace.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/nix/lib/namespace-types.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/nix/lib/aspects/types.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/nix/lib/aspects/fx/key-classification.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/nix/lib/aspects/fx/content-util.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/nix/lib/entities/host.nix`
- `https://raw.githubusercontent.com/denful/den/v0.19.0/templates/ci/modules/public-api/host-aspects.nix`

The default shell is `sh`; `rg` is not installed. Prefer file tools/grep. Follow the terminal schema (explicit cwd, no shell substitutions, bounded runtimes, git read commands with `--no-pager`).
