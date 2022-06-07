{ common, ... }: {
  imports = with common; [
    system-defaults
    system-packages
    homebrew
    fonts
    nix-config
    touchID
    nix-daemon
  ];

  homebrew.casks = [
    "lastpass"
  ];

  system.stateVersion = 4;
}
