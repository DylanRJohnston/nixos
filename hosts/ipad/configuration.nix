{
  common,
  config,
  hardware,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{

  imports = with common; [
    #  code-server
    fonts
    g-ether
    mosh
    nix-config
    openssh
    raspberry-pi
    user
    wifi
    zsh
    ssh-sudo
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "25.05";
}
