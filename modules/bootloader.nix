{
  den,
  arc,
  lib,
  unitTest,
  ...
}:
{
  arc.schema.host.options.boot = lib.mkOption {
    type = den.lib.aspects.types.aspectType;
    default = arc.bootloader._.systemd;
  };

  arc.base.includes = [ arc.base._.bootloader ];

  arc.base._.bootloader = den.lib.perHost ({ host }: host.boot);

  arc.bootloader._.systemd.nixos.boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };

    efi.canTouchEfiVariables = true;
  };

  arc.bootloader._.sd-card.nixos =
    { modulesPath, ... }:
    {
      imports = [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];
    };

  flake.tests.bootloader =
    let
      tests.test-default = {
        boot = lib.mkOverride 1501 null;
        expected = {
          extlinux = false;
          systemd = true;
          canTouch = true;
        };
      };

      tests.test-sd-card = {
        boot = arc.bootloader._.sd-card;
        expected = {
          extlinux = true;
          systemd = false;
          canTouch = false;
        };
      };
    in
    tests
    |> lib.mapAttrs (
      _:
      { boot, expected }:
      unitTest (
        { arc, igloo, ... }:
        {
          den.hosts.x86_64-linux.igloo = {
            inherit boot;
            aspects = [ arc.base ];
          };

          expr = with igloo.boot.loader; {
            extlinux = generic-extlinux-compatible.enable;
            systemd = systemd-boot.enable;
            canTouch = efi.canTouchEfiVariables;
          };

          inherit expected;
        }
      )
    );
}
