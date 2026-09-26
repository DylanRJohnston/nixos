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

[`flake.nix`](./flake.nix) evaluates all Nix files under `modules/` and `hosts/` through [`import-tree`](https://github.com/vic/import-tree). New modules and hosts are discovered automatically without adding explicit imports to the flake.

- [`modules/`](./modules/) defines composable `arc` aspects and their tests.
- [`hosts/`](./hosts/) declares each managed host and the aspects it composes.
- [`docs/architecture/decisions/`](./docs/architecture/decisions/) records significant architecture decisions, alternatives, and supersession history as lightweight ADRs.
- [`agents/`](./agents/) contains current project guidance and focused operational notes for coding agents.

The configuration uses [den](https://github.com/dylanrjohnston/den) to map each host's selected aspects into NixOS, nix-darwin, Home Manager, and user-level configuration.
