# Merge Targets are an intermediate step in the process so that
# other modules can iterate over all machines without causing
# the infinite recursion that would otherwise occur from forcing
# evaluation of the attribute set keys of machines.
# machines -(iter)-> mergeTargets -(iter)-> configurations
# this is an unfortunate limitation of nix even though it's technically
# sound since we don't change the keys
{ lib, config, ... }:
let
  inherit (lib) types mkOption;
  inherit (config) machines;
in
{
  options.mergeTargets = mkOption {
    type = types.lazyAttrsOf (
      types.submodule {
        options = {
          # Initially the machines and merge targets were namespaced
          # by platform, but it resulted in a lot of duplicated logic
          # so I decided to carry the platform information with it
          platform = mkOption {
            type = types.enum [
              "darwin"
              "nixos"
            ];
          };

          module = mkOption {
            type = types.deferredModule;
          };
        };
      }
    );
  };

  # This creates the "initial" merge targets from the machine definitions
  config.mergeTargets =
    machines
    |> lib.mapAttrs (
      _: machine: {
        inherit (machine) platform module;
      }
    );
}
