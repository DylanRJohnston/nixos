{
  pkgs,
  modules,
  ...
}:
{
  imports = [
    modules.wsl
  ];

  custom.roles = [
    "development"
    "entertainment"
    "gaming"
  ];

  networking.hostName = "desktop";
  system.stateVersion = "25.05";

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
