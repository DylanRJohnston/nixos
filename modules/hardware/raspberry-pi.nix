{
  inputs,
  unitTest,
  ...
}:
{
  arc.hardware._.raspberry-pi.nixos = {
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
