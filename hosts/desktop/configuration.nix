{ pkgs, common, modules, ... }:
{
  imports = [
    common.fonts
    common.nix-config
    common.user
    modules.wsl
  ];

  networking.hostName = "desktop";
  system.stateVersion = "23.11";

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


  virtualisation.docker.enable = true;

  services.openssh.enable = true;
  services.openssh.ports = [ 2022 ];
  services.cachix-agent.enable = true;
}
