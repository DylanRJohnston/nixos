{ common
, config
, inputs
, modulesPath
, pkgs
, ...
}: {

  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    common.nix-config
    inputs.hardware.nixosModules.raspberry-pi-4
    common.user
  ];

  # Issue https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  boot.loader.raspberryPi.firmwareConfig = "dtoverlay=dwc2";

  boot.kernelModules = [
    "dwc2"
    "g_ether"
  ];

  hardware.raspberry-pi."4".dwc2.enable = true;

  programs.zsh.enable = true;
}
