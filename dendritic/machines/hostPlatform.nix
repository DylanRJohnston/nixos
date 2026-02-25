{
  self,
  ...
}:
let
  mapPlatformToSystem = arch: if arch == "nixos" then "linux" else arch;

  setHostPlatform = config: {
    module.nixpkgs.hostPlatform = "${config.architecture}-${mapPlatformToSystem config.platform}";
  };
in
{
  mergeTargets = self.lib.perMachine setHostPlatform;
}
