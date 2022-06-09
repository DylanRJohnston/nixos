[![CI](https://github.com/DylanRJohnston/nixos/actions/workflows/CI.yml/badge.svg)](https://github.com/DylanRJohnston/nixos/actions/workflows/CI.yml)

Configuration files for NixOS and Home Manager. Feel free to browse and see what works for you. Reading through other people's configurations was very helpful for me as I was learning Nix.

## Bootstrapping

To bootstrap a Darwin system configuration.

1. **[Install Nix](https://nixos.org/download.html)**

   ```
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. **[Install Homebrew](https://brew.sh/)**

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   ```

3. **[Install Nix Darwin](https://github.com/LnL7/nix-darwin#install)**

   ```bash
   nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
   ./result/bin/darwin-installer
   ```

4. **Clone Repository**

   ```bash
   rm -rf ~/.nixpkgs
   git clone git@github.com:DylanRJohnston/nixos.git ~/.nixpkgs
   ```

5. **Configure System**
   ```bash
   darwin-rebuild switch --flake ~/.nixpkgs
   ```

## Project Structure

[flake.nix](./flake.nix) contains [System Configurations](#system-configurations) and [Templates](#templates).

### System Configurations

`flake.nix` contains a number of system configurations as well as a number of helper methods for constructing Darwin (`mkDarwin`) and NixOS (`mkNixOS`) system configurations which are specialisations of the generic `mkSystem` function.

NixOS or Nix-Darwin modules are provided with a number of extra parameters.

- **lockfile** - The contents of the flake.lock, currently used to pin the `/etc/nix/registry.conf` to the same version as the lockfile. Ensuring all invocations of `nix shell nixpkgs#foobar` use the same `nixpkgs` as the system configuration.
- **hardware** - The [nixos/nixos-hardware](https://github.com/nixos/nixos-hardware) flake contents. Contains hardware specific modules to support things like the Raspberry PI.
- **common** - Contains NixOS modules that are shared between NixOS system configurations.

Home Manager modules are provided similarly with an extra **common** argument that contains shared home-manager modules.

NixOS, Nix Darwin, and Home Manager all have a **common.base** module that contains a sensible collection of modules. Most of the system configurations contain just these base modules with use cases specific overrides. For example, for [AU-L-0226](./hosts/AU-L-0226/) the [NixOS Configuration](./hosts/AU-L-0226/configuration.nix) contains just the base configuration with an additional Homebrew Cask for LastPass. The [Home Manager](./hosts/AU-L-0226/home-manager.nix) module is similarly just the base configuration with overrides for the git config.

### Templates
