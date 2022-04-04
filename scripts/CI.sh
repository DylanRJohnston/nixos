set -xeuo pipefail

nix eval .#nixosConfigurations."dylanj-work-dell".config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations."dylanj-desktop".config.system.build.toplevel.drvPath
nix eval .#darwinConfigurations."macbook-pro".config.system.build.toplevel.drvPath
