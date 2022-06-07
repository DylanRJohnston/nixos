{ hardware, modulesPath, lib, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    hardware.nixosModules.raspberry-pi-4
  ];

  # Issue https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  hardware.raspberry-pi."4" = {
    fkms-3d.enable = true;
  };

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = lib.mkForce [ "nofail" ];
    };
  };
}
