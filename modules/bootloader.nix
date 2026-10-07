{
  den,
  arc,
  lib,
  unitTest,
  ...
}:
{
  arc.schema.host.options.boot = lib.mkOption {
    type = den.lib.aspects.types.providerType;
    default = arc.bootloader._.systemd;
  };

  # arc.base.includes = [ arc.base._.bootloader ];

  arc.base.nixos.boot.zfs.forceImportRoot = false;

  arc.base._.bootloader = { host, ... }: host.boot;

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
          forceImportRoot = false;
        };
      };

      tests.test-invalid-value = {
        boot = 42;
        # Upstream loads provider modules before reporting the option's type error.
        expectedError.msg = "cannot coerce an integer to a string: 42";
      };

      tests.test-undeclared-aspect-option = {
        boot.typo = { };
        expectedError.msg = ''Attempted to set the option "typo"'';
      };

      tests.test-inline-aspect = {
        boot.nixos.boot.loader.generic-extlinux-compatible.enable = true;
        expected = {
          extlinux = true;
          systemd = false;
          canTouch = false;
          forceImportRoot = false;
        };
      };

      tests.test-sd-card = {
        boot = arc.bootloader._.sd-card;
        expected = {
          extlinux = true;
          systemd = false;
          canTouch = false;
          forceImportRoot = false;
        };
      };
    in
    tests
    |> lib.mapAttrs (
      _: test:
      unitTest (
        { arc, igloo, ... }:
        {
          den.hosts.x86_64-linux.igloo = {
            inherit (test) boot;
            aspect.includes = [ arc.base ];
          };

          expr = with igloo.boot.loader; {
            extlinux = generic-extlinux-compatible.enable;
            systemd = systemd-boot.enable;
            canTouch = efi.canTouchEfiVariables;
            forceImportRoot = igloo.boot.zfs.forceImportRoot;
          };
        }
        // builtins.removeAttrs test [ "boot" ]
      )
    );
}
