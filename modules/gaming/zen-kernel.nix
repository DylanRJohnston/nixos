{
  kit.gaming.nixos =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    };
}
