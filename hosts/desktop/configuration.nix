{ lib, pkgs, config, modulesPath, common, wsl, ... }:
{
  imports = [
    common.fonts
    common.nix-config
    common.user
    wsl
  ];

  networking.hostName = "desktop";
  system.stateVersion = "22.05";

  wsl = {
    enable = true;
    defaultUser = "dylanj";
    docker-native.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    nixpkgs-fmt
    tmux
    vim
    vscode
    wget
  ];
}
