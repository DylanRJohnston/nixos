{ common, ... }:
{
  imports = with common; [
    system-defaults
    system-packages
    homebrew
    fonts
    nix-config
    touchID
    nix-daemon
  ];

  system.stateVersion = 5;
  security.pam.enableSudoTouchId = true;
}
