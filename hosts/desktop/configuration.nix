<<<<<<< HEAD
{
  pkgs,
  modules,
  ...
}:
{
  imports = [
    modules.wsl
  ];
||||||| parent of 2183fbc (squash me)
{
  pkgs,
  common,
  modules,
  ...
}:
{
  imports = [
    common.roles
    common.fonts
    common.nix-config
    common.user
    modules.wsl
  ];
=======
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
>>>>>>> 2183fbc (squash me)

<<<<<<< HEAD
  custom.roles = [
    "development"
    "entertainment"
    "gaming"
  ];

  networking.hostName = "desktop";
  system.stateVersion = "25.05";
||||||| parent of 2183fbc (squash me)
  networking.hostName = "desktop";
  system.stateVersion = "25.05";
=======
>>>>>>> 2183fbc (squash me)

{ config, pkgs, common, modules, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      common.base
      common.nix-config
      common.fonts
      modules.jovian
    ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop"; # Define your hostname.

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
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;

  programs.sway.enable = true;
  jovian.steam.enable = true;
  jovian.steam.autoStart = true;
  jovian.steam.user = "dylanj";
  jovian.steam.desktopSession = "sway";

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.bluetooth.enable = true;
  services.getty.autologinUser = "dylanj";

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    gamescope-wsi
    git
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
