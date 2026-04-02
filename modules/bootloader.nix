{ arc, ... }:
{
  arc.base.includes = [ arc.base._.bootloader ];

  arc.base._.bootloader = {
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };

      efi.canTouchEfiVariables = true;
    };
  };
}
