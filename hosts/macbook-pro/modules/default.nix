{ common, ... }: {
  imports = with common; [
    ./homebrew.nix
    ./system-defaults.nix
    ./system-packages.nix
    ./touchID.nix
    fonts
    nix-config
  ];

  programs.zsh.enable = true; # default shell on catalina

  system.stateVersion = 4;
}
