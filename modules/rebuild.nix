{
  arc,
  lib,
  nixosAspectTest,
  ...
}:
{
  arc.base = {
    darwin.security.sudo.extraConfig = ''
      ALL ALL=NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
    '';

    nixos.security.sudo.extraConfig = ''
      %wheel ALL=(root) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild
      %wheel ALL=(root) NOPASSWD: /nix/store/*-nixos-system-*/bin/switch-to-configuration
    '';
  };

  flake.tests.rebuild-sudo = nixosAspectTest {
    aspects = [ arc.base ];
    expr =
      igloo:
      lib.hasInfix
        "%wheel ALL=(root) NOPASSWD: /nix/store/*-nixos-system-*/bin/switch-to-configuration"
        igloo.security.sudo.extraConfig;
    enabled = true;
    disabled = false;
  };
}
