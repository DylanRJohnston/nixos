# 2. Separate hardware profiles from host roles

## Status

Accepted

## Context

The `arc.gaming` role configured both generic gaming support and Loki's NVIDIA driver. This made NVIDIA an implicit consequence of selecting the gaming role, even though the same hardware configuration could be needed by a non-gaming workstation or compute host, and a future gaming host could use AMD or another graphics implementation.

Den config classes such as `.nixos` and `.darwin` select the target configuration system. They do not provide a separate namespace for hardware backends, so a shape such as `arc.gaming.nixos.nvidia` would conflate platform selection with implementation selection.

The following alternatives were considered:

- Keep NVIDIA under `arc.gaming`: rejected because the coupling already misrepresents the configuration and would incorrectly affect a future non-NVIDIA gaming host.
- Define `arc.gaming._.nvidia`: rejected because it still makes the vendor implementation subordinate to the gaming role.
- Add a host GPU flag or selector and make a meta-aspect dispatch to NVIDIA or AMD: deferred because there is only one implementation, some hosts need no explicit GPU profile, and multi-GPU hosts may not fit an exactly-one selector.
- Build a shared GPU capability interface: deferred until multiple implementations or consumers establish concrete common requirements.

## Decision

Role aspects and implementation profiles are independent composition dimensions.

- Vendor-specific NVIDIA configuration is provided by `arc.hardware._.nvidia.nixos` in `modules/hardware/nvidia.nix`.
- Hosts select hardware profiles explicitly in their `aspects` list. Loki composes `arc.gaming`, `arc.interactive`, and `arc.hardware._.nvidia`.
- `arc.gaming` retains vendor-neutral gaming requirements, including 32-bit graphics support for game runtimes.
- Hardware profiles may enable generic prerequisites needed to be self-contained, even when another selected role also enables the same mergeable NixOS option.
- No automatic GPU selector, dispatch layer, or abstract capability interface is introduced until a real additional implementation or consumer justifies it.

## Consequences

Gaming configuration no longer selects a GPU vendor, and the NVIDIA profile can be reused independently of gaming. A future AMD gaming host can select `arc.gaming` without receiving NVIDIA configuration and only needs an AMD profile if explicit AMD configuration is actually required.

Host declarations gain one explicit hardware aspect. Some mergeable generic settings, such as enabling graphics support, may be contributed by both a role and a hardware profile so each remains usable independently.

There is currently no schema enforcing exactly one GPU implementation or automatically dispatching based on host metadata. If future hosts demonstrate that need, a later ADR should define the selector or capability model and supersede the deferred portion of this decision.
