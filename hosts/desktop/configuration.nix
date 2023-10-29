{ pkgs, common, modules, ... }:
{
  imports = [
    common.fonts
    common.nix-config
    common.user
    modules.wsl
  ];

  networking.hostName = "desktop";
  system.stateVersion = "23.05";

  wsl = {
    enable = true;
    defaultUser = "dylanj";
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
