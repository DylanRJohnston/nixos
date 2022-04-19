set -xeuo pipefail

nix eval ".#nixosConfigurations.work-dell.config.system.build.toplevel.drvPath"
nix eval ".#nixosConfigurations.desktop.config.system.build.toplevel.drvPath"
nix eval ".#darwinConfigurations.macbook-pro.config.system.build.toplevel.drvPath"
