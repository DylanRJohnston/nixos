This directory is for config files where authoring them through nix is too much of a pain in the ass (e.g. vscode, zed, etc) and you'd prefer to edit them via their respective tooling while still syncing them between machines.

This is achieved using home-manager's `mkOutOfStoreSymlink` see the [zed config](../common/home-manager/zed.nix). User polymorphism is achieved via the config fixed point `config.home.homeDirectory` which is set in the outer `home-manager-config` in [flake.nix](../flake.nix).
