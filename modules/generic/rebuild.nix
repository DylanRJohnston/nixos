{
  flake.modules.generic.base =
    {
      pkgs,
      ...
    }:
    let
      rebuild =
        if pkgs.stdenv.isLinux then
          "/run/current-system/sw/bin/nixos-rebuild"
        else if pkgs.stdenv.isDarwin then
          "/run/current-system/sw/bin/darwin-rebuild"
        else
          throw "Unsupported platform, isLinux and isDarwin are both false";
    in
    {
      security.sudo.extraConfig = ''
        ALL ALL=NOPASSWD: ${rebuild}
      '';
    };
}
