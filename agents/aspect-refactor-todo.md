# Aspect Refactor Backlog

This is an agent-facing backlog for known aspect-boundary improvements. These items are intentionally deferred: do not fold them into unrelated tasks. Before moving configuration, inspect all platform-specific effects and add focused `unitTest` coverage proving both inclusion and exclusion where practical.

## Audit `arc.base`

`arc.base` must contain only configuration intended for every managed host. For each candidate below, determine whether it belongs in `arc.interactive`, `arc.development`, another capability aspect, or an explicit host selection.

- [ ] Audit `arc.base._.bluetooth`; Bluetooth is not necessarily universal, especially on headless hosts.
- [ ] Move graphical font configuration from `arc.base` to `arc.interactive` unless a non-GUI consumer requires it.
- [ ] Audit NixOS base GUI packages in `modules/packages.nix`, including `_1password-gui`, Obsidian, and PulseAudio.
- [ ] Classify every Darwin base cask in `modules/packages.nix`; likely destinations include `interactive`, `development`, `entertainment`, or a more specific capability.
- [ ] Audit GUI-oriented base modules and applications such as Zed and WezTerm.
- [ ] Keep light remote-maintenance tools in `base` when they are genuinely useful for administering every host, even if they are also development tools.

## Expand `arc.interactive`

`arc.interactive` is cross-platform and represents hosts with an attached display or graphical session. Its adoption is an ongoing refactor.

- [ ] Add `arc.interactive` to Odin after Darwin-relevant graphical configuration has been moved under it and evaluated.
- [ ] Audit desktop portals, audio desktop integration, fonts, browsers, password-manager GUIs, notifications, clipboard tools, and display-temperature services for placement under `interactive`.
- [ ] Decide whether Plymouth is graphical/system presentation (`interactive`) rather than entertainment.
- [ ] Decide whether selecting Niri should remain automatic for every interactive NixOS host or become a separate explicit compositor/session choice.
- [ ] Keep compositor-specific configuration out of generic interactive modules unless every relevant host should inherit it.

## Clarify `arc.development`

Use `development` for substantial project development, not the minimum tools needed to remotely repair or reconfigure a host.

- [ ] Audit heavy development applications currently in base, including Docker Desktop, DBeaver, Postman, and Zed.
- [ ] Audit CLI tools such as `nixd`, `nix-unit`, Git Town, Commitizen, and language/toolchain packages; retain only genuinely universal maintenance tools in base.
- [ ] If a real host needs headless development without GUI development applications, consider an opt-in `arc.development._.graphical` sub-aspect or another composition mechanism. Do not introduce this abstraction without a concrete need.

## Correct entertainment and gaming boundaries

`entertainment` is discretionary non-gaming media/social software excluded from focused machines. `gaming` is software and configuration used to run, optimise, or stream games.

- [ ] Move Discord from `arc.gaming` to `arc.entertainment` if the current policy remains that Discord is distracting social software rather than a gaming runtime dependency.
- [ ] Review Firefox: a general browser likely belongs to `interactive`, not `entertainment`.
- [ ] Review GIMP and Audacity: creative tools may deserve a different role from entertainment.
- [ ] Review Slack and Signal according to personal work/social policy rather than generic application categories.
- [ ] Keep Steam, GameMode, MangoHud, Sunshine, gaming kernels, compatibility layers, and controller support under `gaming` where applicable.

## Evolve `arc.mesh`

`arc.mesh` represents trusted Tailscale-network membership and associated access policy.

- [ ] Evaluate replacing cross-host OpenSSH key distribution with Tailscale SSH.
- [ ] If migrating, update or retire `arc.mesh._.keys` and the relevant parts of `arc.mesh._.ssh` without changing the top-level meaning of `arc.mesh`.
- [ ] Preserve ordinary SSH separately wherever it is still needed outside the Tailscale trust path.
- [ ] Update mesh unit tests to cover the chosen trust and access model.

## Validation for aspect moves

For each migration:

- [ ] Keep sub-aspect registration in the module that defines the sub-aspect.
- [ ] Add or update a focused `unitTest` for a host that includes the parent aspect.
- [ ] Add a negative test for a host that omits the parent aspect when the option has a meaningful default or observable absence.
- [ ] Run the focused suite with `nix-unit --flake '.#tests.<name>'`.
- [ ] Run `nix flake check --no-build` after related moves are complete.
