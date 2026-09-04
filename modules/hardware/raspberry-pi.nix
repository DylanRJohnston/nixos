{
  inputs,
  unitTest,
  ...
}:
{
  arc.hardware._.raspberry-pi.nixos =
    { pkgs, ... }:
    {
      imports = [
        inputs.hardware.nixosModules.raspberry-pi-4
      ];

      # Build the aarch64 Raspberry Pi kernel natively on x86_64 builders.
      boot.kernelPackages =
        let
          crossPkgs = import pkgs.path {
            localSystem = "x86_64-linux";
            crossSystem = pkgs.stdenv.hostPlatform.system;
          };
          kernel = crossPkgs.callPackage (inputs.hardware.outPath + "/raspberry-pi/common/kernel.nix") {
            rpiVersion = 4;
          };
        in
        crossPkgs.linuxPackagesFor kernel;

      # Issue https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

      hardware.raspberry-pi."4" = {
        bluetooth.enable = true;
        fkms-3d.enable = true;
      };
    };

  flake.tests.raspberry-pi = {
    test-bluetooth-enabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.aarch64-linux.igloo.aspects = [ arc.hardware._.raspberry-pi ];

        expr = igloo.hardware.raspberry-pi."4".bluetooth.enable;
        expected = true;
      }
    );

    test-kernel-cross-compiled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.aarch64-linux.igloo.aspects = [ arc.hardware._.raspberry-pi ];

        expr = {
          buildPlatform = igloo.boot.kernelPackages.kernel.stdenv.buildPlatform.system;
          hostPlatform = igloo.boot.kernelPackages.kernel.stdenv.hostPlatform.system;
        };
        expected = {
          buildPlatform = "x86_64-linux";
          hostPlatform = "aarch64-linux";
        };
      }
    );

    test-bluetooth-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.aarch64-linux.igloo.aspects = [ arc.base ];

        expr = igloo.hardware.raspberry-pi."4".bluetooth.enable;
        expectedError.msg = "attribute 'raspberry-pi' missing";
      }
    );
  };
}
