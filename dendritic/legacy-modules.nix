{
  # Fully migrated
  # flake.modules.darwin.base.imports = [ (import ../modules/darwin) ];
  # flake.modules.generic.base.imports = [ (import ../modules/shared) ];
  flake.modules.homeManager.base.imports = [ (import ../modules/home-manager) ];
  flake.modules.nixos.base.imports = [ (import ../modules/nixos) ];
}
