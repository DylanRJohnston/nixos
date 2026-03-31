{ den, ... }:
{
  kit.gaming = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        boot.kernelPackages = pkgs.linuxPackages_zen;
      };
  };
}
