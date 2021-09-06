{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";

    libinput.enable = true;
    libinput.touchpad.naturalScrolling = true;

    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+i3";
    displayManager.lightdm.greeters.mini.enable = true;
    displayManager.lightdm.greeters.mini.user = "dylanj";
    displayManager.lightdm.greeters.mini.extraConfig = ''
      [greeter]
      active-monitor=1
    '';

    desktopManager.xterm.enable = false;

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
        i3lock-fancy
      ];
    };
  };
}
