# The `arc` Aspect System

## What is an aspect?

An aspect is a named, composable unit of configuration. Each aspect can carry config for any combination of targets (nixos, darwin, homeManager, user, os). Hosts opt into a set of aspects, and the framework fans out each aspect's config to the right target.

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
aspects = [
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

Use host schema values for facts about machine topology or capabilities that multiple aspects may consume, such as a bulk-storage root. Define the behavior-free option under `arc.schema.host`, configure it in the host declaration, and consume it through `den.lib.perHost`. Prefer a nullable default when hosts that do not use the dependent aspect should remain valid.

Use direct aspect parameters for values specific to one aspect invocation or instance. Remember that direct parameters must be propagated through every aspect inclusion layer, so they are a poor fit for shared host facts.

When an aspect requires a nullable host value, place a clear assertion directly alongside the configuration that consumes it. Nix module values are lazy, so the assertion and dependent definitions can ordinarily remain in one module attrset without defensive `mkIf`, `mkMerge`, placeholder paths, or a separate `config` block:

```nix
arc.services._.example = den.lib.perHost (
  { host }:
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
  }
);
```

Test both a configured synthetic host and a host that selects the aspect without the required value. The latter can inspect the final `assertions` entry to verify both the failed condition and the operator-facing message.

## How hosts use aspects

Hosts are defined in `hosts/<name>/<name>.nix`:

```nix
{ arc, ... }: {
  den.hosts.x86_64-linux.loki = {
    users.dylanj.key = "ssh-ed25519 ...";
    aspects = [
      arc.base
      arc.gaming
      arc.interactive
    ];
  };
}
```

Inline aspect fragments are also valid for one-off host-specific settings:

```nix
aspects = [
  arc.base
  { nixos.boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; }
  { user.extraGroups = [ "dialout" ]; }
];
```
