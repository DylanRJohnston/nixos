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
      %wheel ALL=(root) NOPASSWD: /run/current-system/sw/bin/nix build --no-link --profile /nix/var/nix/profiles/system /nix/store/*-nixos-system-*
    '';
  };

  flake.tests.rebuild-sudo = nixosAspectTest {
    aspects = [ arc.base ];
    expr =
      igloo:
      let
        sudoConfig = igloo.security.sudo.extraConfig;
      in
      {
        switchToConfiguration = lib.hasInfix "%wheel ALL=(root) NOPASSWD: /nix/store/*-nixos-system-*/bin/switch-to-configuration" sudoConfig;
        setSystemProfile = lib.hasInfix "%wheel ALL=(root) NOPASSWD: /run/current-system/sw/bin/nix build --no-link --profile /nix/var/nix/profiles/system /nix/store/*-nixos-system-*" sudoConfig;
      };
    enabled = {
      switchToConfiguration = true;
      setSystemProfile = true;
    };
    disabled = {
      switchToConfiguration = false;
      setSystemProfile = false;
    };
  };
}
