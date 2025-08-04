{ common, ... }:
{
  imports = with common; [
    system-defaults
    system-packages
    homebrew
    fonts
    nix-config
    touchID
  ];

  system.stateVersion = 5;
  security.pam.enableSudoTouchId = true;
}
