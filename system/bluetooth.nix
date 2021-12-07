{ pkgs, ... }: {
  sound.enable = true;

  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    bluetooth = {
      enable = true;
      disabledPlugins = [ "sap" ];
    };
  };
}
