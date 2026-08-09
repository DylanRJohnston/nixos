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
