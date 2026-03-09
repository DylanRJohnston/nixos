{
  flake.modules.darwin.base.security.sudo.extraConfig = ''
    ALL ALL=NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';

  flake.modules.nixos.base.security.sudo.extraConfig = ''
    ALL ALL=NOPASSWD: /run/current-system/sw/bin/nixos-rebuild
  '';
}
