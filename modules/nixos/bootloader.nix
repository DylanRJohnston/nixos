{ kit, ... }:
{
  kit.base.includes = [ kit.base._.bootloader ];

  kit.base._.bootloader = {
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };

      efi.canTouchEfiVariables = true;
    };
  };
}
