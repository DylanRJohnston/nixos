# Agent Notes

## Project Overview

A personal Nix configuration using `flake.nix` with [den](https://github.com/dylanrjohnston/den) as the underlying framework and `import-tree` for module discovery.

## Module Auto-Discovery

All `.nix` files under `./modules` and `./hosts` are automatically imported via `import-tree`. **Never edit `flake.nix` to add imports** — just place a new `.nix` file in the right directory.

## Git Working Tree and Staging

Inspect the Git status near the start of each task. The expected workflow is either a fresh working tree for a new feature or existing changes that are relevant to debugging, completing, or polishing the current task. If uncommitted changes appear unrelated to the user's request, warn the user before making edits; if they overlap files that need modification or make intent ambiguous, ask how to proceed. Never discard or overwrite unrelated work.

Agents have permission to modify the Git staging area. In particular, stage newly created files before evaluating Git-backed flake outputs so auto-discovered modules and their tests are visible to Nix. Preserve any pre-existing staged work and do not reset or unstage it.

## Config Classes

Each aspect can define config for different targets using these keys:

| Key            | Applies to                        |
|----------------|-----------------------------------|
| `.nixos`       | NixOS systems only                |
| `.darwin`      | macOS (nix-darwin) systems only   |
| `.os`          | Both NixOS and macOS              |
| `.homeManager` | home-manager (all platforms)      |
| `.user`        | User-level config                 |

## The `arc` Aspect System

This codebase is organised around **aspects** — named, composable units of configuration. Understanding this is essential for any module work.

- Aspects live at `arc.<name>` (e.g. `arc.base`, `arc.gaming`, `arc.interactive`)
- Hosts opt into aspects via their `aspects = [ ... ]` list in `hosts/<name>/<name>.nix`
- Named sub-aspects (`arc.<aspect>._.<name>`) exist for debuggability — they are **not** automatically included; their parent must explicitly include them
- `arc.interactive` represents machines with an attached display. Graphical settings, desktop integration, GUI toolkits, and similar configuration belong under it rather than `arc.base`, so headless hosts remain unaffected.

### Host-facing Aspect Intent

Use these definitions and litmus tests when deciding where configuration belongs:

- **`arc.base` — universal baseline.** It contains only configuration that should apply to every managed host. If any present or plausible future host should not receive something, move it out of `base`. Light remote administration and reconfiguration tools such as Git, Vim, tmux, and basic Nix tooling may remain here.
- **`arc.interactive` — locally graphical machines.** It contains configuration useful when a host has an attached display or graphical session: compositors, desktop integration, GUI toolkits, themes, fonts, portals, notifications, and general graphical applications. It is cross-platform in intent, even though adoption on Darwin is still in progress.
- **`arc.development` — substantial software-development capability.** It contains heavy or specialised tools used to build, test, debug, and deploy projects. Ask whether a tool is needed merely to administer or lightly reconfigure a machine (`base`) or to use it as a serious development environment (`development`). A gaming appliance such as a Steam Deck should not need this aspect just to remain maintainable.
- **`arc.entertainment` — optional non-gaming media and social software.** It contains distracting or discretionary applications that should be absent from focused/work-only machines, such as media consumption and personal social applications. This is a personal policy boundary rather than a generic software taxonomy.
- **`arc.gaming` — game execution and support.** It contains game clients, compatibility layers, performance tooling, streaming, controller support, and gaming-specific system configuration. It applies to gaming machines, not general servers or Raspberry Pis.
- **`arc.mesh` — trusted private-network membership.** It opts a host into the Tailscale mesh and the access/trust configuration shared by participating hosts, currently including SSH/Mosh and cross-host key distribution. Implementations may change (for example, to Tailscale SSH) without changing the aspect's intent.

Selector namespaces such as `arc.bootloader` and `arc.hardware` provide implementations or profiles rather than broad machine roles. `arc.schema` and `arc.ctx` are framework internals.

### Universal Schema vs. Baseline Behavior

Keep `arc.base` explicit and host-facing; do not make the whole aspect implicit through `arc.ctx`. Put behavior-free option declarations and composition plumbing that every host must understand under `arc.ctx.host`, especially when one optional aspect registers configuration consumed by another. Keep packages, services, policy, and other runtime effects under `arc.base` or a more specific opt-in aspect. A module failing to evaluate without `base` may indicate misplaced universal schema or an undeclared aspect dependency; do not make `base` implicit merely to hide that distinction.

Deferred aspect-boundary audits and migrations are tracked in [`agents/aspect-refactor-todo.md`](agents/aspect-refactor-todo.md). Do not perform those unrelated refactors opportunistically while completing another task.

### Sub-aspect Registration

When a module defines a sub-aspect that should always accompany its parent, register the inclusion in the same module:

```nix
arc.interactive.includes = [ arc.interactive._.darkmode ];
arc.interactive._.darkmode = { ... };
```

Do not register one module's sub-aspect from an unrelated module, such as registering dark mode from a compositor module.

> For full details on the aspect system, named sub-aspects, includes, and worked examples, see [`agents/aspect-system.md`](agents/aspect-system.md).
> Read this before adding, restructuring, or debugging any module.

## Host Files

Hosts live under `hosts/<name>/<name>.nix` (or `hosts/<name>.nix` for simple cases). They declare the host's system, users, and which aspects apply.

## Unit Tests

Every new feature and every refactor must include a black-box unit test. Use the `unitTest` helper from `modules/unit-test.nix` to define a synthetic host and assert against its final evaluated configuration. Tests must verify externally observable host behavior rather than implementation details such as the contents of an aspect's `includes` list.

For aspect-scoping changes, test both a host that includes the aspect and one that omits it. A refactor should preserve or deliberately update the existing behavioral assertions, while a new feature should cover its intended enabled behavior and any meaningful exclusion or default behavior.

When the same expression succeeds with an aspect and naturally fails without it, prefer asserting the evaluation error (`expectedError`, or `disabledErr` with an aspect test helper) over adding defensive field-access logic such as presence checks and conditional placeholder values solely to keep the expression evaluable. Incrementally simplify existing tests that use such defensive access when working in those files, but do not broaden an unrelated task into a repository-wide test refactor.

Do not consider a feature or refactor complete until its focused black-box test suite passes.

```nix
flake.tests.feature.test-included = unitTest (
  { arc, igloo, ... }:
  {
    den.hosts.x86_64-linux.igloo.aspects = with arc; [
      base
      interactive
    ];

    expr = igloo.some.option;
    expected = true;
  }
);
```

Run a focused test suite with:

```bash
nix-unit --flake '.#tests.feature'
```
