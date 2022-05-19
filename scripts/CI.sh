set -xeuo pipefail

nix eval ".#nixosConfigurations.work-dell.config.system.build.toplevel.drvPath"
nix eval ".#nixosConfigurations.desktop.config.system.build.toplevel.drvPath"
nix eval ".#nixosConfigurations.ipad.config.system.build.toplevel.drvPath"
# Github Actions are no longer able to build evaluate this derivation anymore, unsure why
# nix eval ".#darwinConfigurations.macbook-pro.config.system.build.toplevel.drvPath"
