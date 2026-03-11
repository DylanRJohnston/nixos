{
  den.aspects.base = {
    darwin.security.sudo.extraConfig = ''
      ALL ALL=NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
    '';

    nixos.security.sudo.extraConfig = ''
      ALL ALL=NOPASSWD: /run/current-system/sw/bin/nixos-rebuild
    '';
  };
}
