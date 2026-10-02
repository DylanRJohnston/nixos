# The `arc` Aspect System

## What is an aspect?

An aspect is a named, composable unit of configuration. Each aspect can carry config for any combination of targets (nixos, darwin, homeManager, user, os). Hosts opt into a set of aspects, and the framework fans out each aspect's config to the right target.

## Upstream den 0.19 integration

Hosts select configuration through `den.hosts.<system>.<name>.aspect.includes`. The host's `aspects` field is read-only resolved-tree introspection, not an input. An explicit `aspect.includes` list replaces the default named `den.aspects.<name>` selection: include that named aspect explicitly when it carries hardware or other host-specific configuration. This also applies to synthetic hosts.

`modules/host-aspects.nix` registers `den.batteries.host-aspects` directly in `den.schema.user.includes`, defaults user classes to `[ "user" "homeManager" ]`, and exports the same integration through `flake.flakeModule` for importing consumers and unit tests. Do not move this projection hook to `arc.schema.user.includes`: that deferred-module transport preserves instance configuration but does not activate the required schema-level hook.

Native integration projects transitive host-selected content into separate destinations: host platform and `os` configuration at the OS root, `user` configuration in `users.users.<userName>`, and `homeManager` configuration in `home-manager.users.<userName>`. The two user classes select environments; they do **not** combine OS user and Home Manager module evaluations. HM retains its own `config` and `pkgs`.

Keep the OS Home Manager shim in `modules/home-manager.nix`: the `os` class declares a deferred `homeManager` option, and the HM class imports `osConfig.homeManager`. This supports `aspect.nixos.homeManager`, `aspect.darwin.homeManager`, and `aspect.os.homeManager` alongside direct `aspect.homeManager` projection. Keep explicit platform HM module imports too: `arc.base` must evaluate on hosts with no users, where native automatic HM detection does not activate.

Strict namespace integration in `modules/namespace.nix` declares the five class options as deferred modules and removes exported provides-navigation aliases before re-importing the namespace. Preserve strict mode rather than treating navigation aliases as configuration options.

User SSH public keys **must** be assigned as `users.<name>.config.key`. Upstream `configOf` strips a top-level `key` as module metadata, so `users.<name>.key` silently leaves the declared user key at its default. Focused mesh tests confirmed that changing only this assignment restores cross-host keys; it is not a namespace closure or projection defect.

See [ADR 0003](../docs/architecture/decisions/0003-adopt-upstream-den-host-projection.md) for the migration decision and tradeoffs. Architectural adoption does not imply final migration CI or build validation has passed.

Aspect context functions can request handler-provided arguments directly, for example `{ host, ... }: ...`. Do not wrap them in `den.lib.take.upTo`; that helper is deprecated because `bind.fn` resolves arguments from handlers.

## Aspect config classes

```nix
arc.gaming.nixos      = { ... };   # NixOS system config
arc.gaming.darwin     = { ... };   # nix-darwin config
arc.gaming.os         = { ... };   # both nixos and darwin
arc.gaming.homeManager = { ... };  # home-manager config
arc.gaming.user       = { ... };   # user-level config
```

When a class value needs access to `pkgs`, `config`, etc., use a module function:

```nix
arc.gaming.nixos = { pkgs, config, ... }: {
  environment.systemPackages = [ pkgs.steam ];
};
```

When it doesn't, a plain attrset works:

```nix
arc.gaming.nixos.hardware.graphics.enable = true;
```

## Named provided sub-aspects (`_`)

The `_` namespace holds **named sub-aspects**. These exist primarily for debuggability: when Nix reports a conflict or unexpected value, the error trace includes the full aspect path (e.g. `arc.base.provides.bluetooth.provides.high_quality_audio.nixos`), making it immediately clear where the option was set.

Sub-aspects are **not** automatically included when their parent is included. Inclusion must be explicit.

### Patterns

**Define a sub-aspect:**

```nix
arc.base._.bluetooth.nixos.hardware.bluetooth = {
  enable = true;
};
```

**Auto-include a sub-aspect with its parent:**

```nix
arc.base.includes = [ arc.base._.bluetooth ];

# bluetooth will auto-include high_quality_audio:
arc.base._.bluetooth.includes = [ arc.base._.bluetooth._.high_quality_audio ];

arc.base._.bluetooth._.high_quality_audio.nixos = {
  security.rtkit.enable = true;
  services.pipewire.enable = true;
};
```

**Opt-in from a host (for optional sub-aspects not in `.includes`):**

```nix
aspect.includes = [
  arc.base
  arc.base._.bluetooth._.debug  # explicitly pulled in for this host only
];
```

## Grouping config under `.nixos`

Prefer a single attrset assignment when setting multiple related NixOS options on the same aspect:

```nix
# Preferred — one assignment, clear scope
arc.base._.bluetooth._.high_quality_audio.nixos = {
  security.rtkit.enable = true;
  services.pipewire.enable = true;
  services.blueman.enable = true;
};
```

Avoid mixing a top-level attrset assignment with separate dot-path assignments at the same level — Nix will report a duplicate definition error.

## Universal schema and host-facing behavior

`arc.ctx.host` and `arc.base` serve different purposes even when nearly every real host selects `base`:

- **`arc.ctx.host` is universal evaluation plumbing.** Put behavior-free option declarations, schema, and composition machinery here when every host must understand them. This is particularly important when one optional aspect registers values that another optional aspect consumes.
- **`arc.base` is explicit baseline behavior.** Keep packages, enabled services, security policy, administration defaults, and other runtime effects here only when they should apply to every managed host.

Do not make all of `arc.base` implicit by including it from `arc.ctx.host`. Doing so would make minimal and synthetic hosts receive hidden behavior, weaken negative tests, and conceal undeclared dependencies. Instead, make evaluation independent of `base` where appropriate by moving only universal, behavior-free declarations into context.

For example, an option allowing applications to register Tailscale Serve endpoints can be universally declared without activating Tailscale:

```nix
# Every host can evaluate aspects that register endpoints.
arc.ctx.host.nixos.options.services.tailscale-serve = lib.mkOption {
  type = lib.types.lazyAttrsOf endpointType;
  default = { };
};

# Only mesh members apply those registrations at runtime.
arc.mesh._.services.nixos = { config, ... }: {
  systemd.services.tailscale-serve = {
    # Build the service from config.services.tailscale-serve.
  };
};
```

When a module fails without `arc.base`, determine which case applies rather than automatically adding `base`:

1. A behavior-free option declaration or composition primitive belongs in `arc.ctx.host`.
2. The module has a real runtime dependency that should be expressed through aspect composition.
3. The synthetic test is intended to represent a normal managed host and should explicitly include `arc.base`.
4. The dependency is accidental and should be removed.

## Host context values vs. direct aspect parameters

Use host schema values for facts about machine topology or capabilities that multiple aspects may consume, such as a bulk-storage root. Define the behavior-free option under `arc.schema.host`, configure it in the host declaration, and consume it through a plain aspect context function (`{ host, ... }: { ... }`), not the deprecated `den.lib.perHost`. Prefer a nullable default when hosts that do not use the dependent aspect should remain valid.

Use direct aspect parameters for values specific to one aspect invocation or instance. Remember that direct parameters must be propagated through every aspect inclusion layer, so they are a poor fit for shared host facts.

When an aspect requires a nullable host value, place a clear assertion directly alongside the configuration that consumes it. Nix module values are lazy, so the assertion and dependent definitions can ordinarily remain in one module attrset without defensive `mkIf`, `mkMerge`, placeholder paths, or a separate `config` block:

```nix
arc.services._.example =
  { host, ... }:
  {
    nixos = {
      assertions = [
        {
          assertion = host.bulkStoragePath != null;
          message = "arc.services._.example requires host.bulkStoragePath to be defined";
        }
      ];

      systemd.tmpfiles.rules = [
        "d ${host.bulkStoragePath}/example 0755 root root -"
      ];
    };
  };
```

Test both a configured synthetic host and a host that selects the aspect without the required value. The latter can inspect the final `assertions` entry to verify both the failed condition and the operator-facing message.

## Roles and implementation profiles

Role aspects describe what a host is used for, while selector namespaces describe concrete implementations or hardware profiles. Compose these independently in the host:

```nix
aspect.includes = [
  arc.gaming
  arc.hardware._.nvidia
  arc.interactive
];
```

Do not place a vendor implementation under the role that currently uses it. For example, NVIDIA configuration belongs in `arc.hardware._.nvidia.nixos`, not `arc.gaming._.nvidia.nixos` or `arc.gaming.nixos.nvidia`. The `.nixos` class selects the target platform; it does not select a hardware backend.

Prefer explicit host composition until multiple real implementations demonstrate a need for host schema, automatic dispatch, or a shared capability interface. See [ADR 0002](../docs/architecture/decisions/0002-separate-hardware-profiles-from-host-roles.md).

## How hosts use aspects

Hosts are defined under `hosts/<name>/<name>.nix`:

```nix
{ arc, den, ... }: {
  den.hosts.x86_64-linux.loki = {
    users.dylanj.config.key = "ssh-ed25519 ...";
    aspect.includes = [
      den.aspects.loki
      arc.base
      arc.gaming
      arc.hardware._.nvidia
      arc.interactive
    ];
  };
}
```

Inline aspect fragments are also valid for one-off host-specific settings:

```nix
aspect.includes = [
  arc.base
  { nixos.boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; }
  { user.extraGroups = [ "dialout" ]; }
];
```
