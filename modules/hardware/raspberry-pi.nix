{ inputs, ... }: {
  arc.hardware._.raspberry-pi.nixos =
    { pkgs, ... }:
    {
      imports = [
        inputs.hardware.nixosModules.raspberry-pi-4
      ];

      # Issue https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
      nixpkgs.overlays = [
        (final: super: {
          makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];

      hardware.raspberry-pi."4" = {
        fkms-3d.enable = true;
      };
    };
}
