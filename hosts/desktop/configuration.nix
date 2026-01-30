{ modules, pkgs, ... }:
{
  custom.roles = [
    "development"
    "entertainment"
    "gaming"
  ];

  networking.hostName = "desktop";
  system.stateVersion = "25.11";

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    modules.jovian
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "Australia/Perth";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dylanj = {
    isNormalUser = true;
    description = "Dylan Johnston";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    vim
    gamescope-wsi
    git
  ];

  programs.ssh.startAgent = true;
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  #
  #  Graphics
  #
  # This also works for wayland
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };

  #
  #  Desktop
  #
  services.dbus.enable = true;
  programs.sway.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  services.greetd = let
    # Small wrapper so greetd launches a predictable environment and logs crashes.
    swayRun = pkgs.writeShellScriptBin "sway-run" ''
      set -euo pipefail

      # Log to the journal (view with: journalctl -t sway-run -b)
      exec 1> >(systemd-cat -t sway-run) 2>&1

      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
      export XDG_CURRENT_DESKTOP=sway
      export SDL_VIDEODRIVER=wayland
      export MOZ_ENABLE_WAYLAND=1

      # If you use a specific terminal/launcher, set it here if you want:
      # export TERMINAL=foot

      exec ${pkgs.sway}/bin/sway --unsupported-gpu
    '';
  in {
    enable = true;
    settings = {
      default_session = {
        user = "dylanj"; command = "${swayRun}/bin/sway-run";
      };
    };
  };
}
