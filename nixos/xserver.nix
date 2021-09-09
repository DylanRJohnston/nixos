{ pkgs, ... }: {
  services.autorandr.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";

    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };

    displayManager = {
      defaultSession = "none+i3";

      autoLogin = {
        enable = true;
        user = "dylanj";
      };

      lightdm.enable = true;
    };

    desktopManager.xterm.enable = false;

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraPackages = with pkgs; [
        dmenu
      ];
    };
  };
}
