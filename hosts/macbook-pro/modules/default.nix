{ common, ... }: {
  imports = with common; [
    ./homebrew.nix
    ./system-defaults.nix
    ./system-packages.nix
    ./touchID.nix
    fonts
    nix-config
  ];

  services.nix-daemon.enable = true;

  programs.zsh.enable = true; # default shell on catalina

  system.stateVersion = 4;
}
