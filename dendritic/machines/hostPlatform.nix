{ lib, config, ... }:
let
  inherit (config.flake) machines;

  mapPlatformToSystem = arch: if arch == "nixos" then "linux" else arch;

  setHostPlatform = config: {
    module.nixpkgs.hostPlatform = "${config.architecture}-${mapPlatformToSystem config.platform}";
  };
in
{
  flake.mergeTargets = machines |> lib.mapAttrs (_: setHostPlatform);
}
