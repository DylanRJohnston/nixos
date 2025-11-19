{ common, ... }:
{
  imports = with common; [
    fonts
    homebrew
    nix-config
    nix-daemon
    system-defaults
    system-packages
    touchID
  ];

  system.stateVersion = 5;
  security.pam.enableSudoTouchId = true;
}
