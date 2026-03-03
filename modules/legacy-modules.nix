{
  # Fully migrated
  # flake.modules.darwin.base.imports = [ (import ../legacyModules/darwin) ];
  # flake.modules.generic.base.imports = [ (import ../legacyModules/shared) ];
  # flake.modules.homeManager.base.imports = [ (import ../legacyModules/home-manager) ];
  flake.modules.nixos.base.imports = [ (import ../legacyModules/nixos) ];
}
