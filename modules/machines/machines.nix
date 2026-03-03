{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.machines = mkOption {
    type = types.lazyAttrsOf (
      types.submodule {
        options = {
          platform = mkOption {
            type = types.enum [
              "darwin"
              "nixos"
            ];
          };

          architecture = mkOption {
            type = types.enum [
              "x86_64"
              "aarch64"
            ];
          };

          roles = mkOption {
            type = types.listOf (
              types.enum [
                "base"
                "development"
                "entertainment"
                "gaming"
                "home-automation"
              ]
            );
          };

          module = mkOption {
            type = types.deferredModule;
          };
        };
      }
    );
  };
}
