let
  # Needs to be deferred because we want den.hosts to be at the import site
  deferredModule =
    { den, lib, ... }:
    {
      arc.mesh._.keys.os.users.users =
        den.hosts
        |> lib.attrValues
        |> lib.map lib.attrValues
        |> lib.flatten
        |> lib.map (it: it.users)
        |> lib.map lib.attrValues
        |> lib.flatten
        |> lib.groupBy (it: it.userName)
        |> lib.mapAttrs (_: users: users |> lib.map (it: it.key) |> lib.filter (it: it != null))
        |> lib.mapAttrs (_: keys: { openssh.authorizedKeys.keys = keys; });
    };
in
{
  lib,
  arc,
  unitTest,
  ...
}:
{
  imports = [ deferredModule ];
  flake.flakeModule = deferredModule;

  arc.mesh.includes = [
    arc.mesh._.tailscale
    arc.mesh._.ssh
    arc.mesh._.keys
  ];

  arc.mesh._.tailscale.os.services.tailscale.enable = true;

  arc.mesh._.ssh = {
    nixos.mosh.enable = true;

    os.services.openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        PermitRootLogin no
      '';
    };
  };

  arc.schema.user.options.key = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "SSH public key";
  };

  flake.tests.mesh.test-cross-host-keys = unitTest (
    { arc, config, ... }:
    {
      den.hosts.aarch64-darwin.apple = {
        users.kiki = { };
        users.boba.key = "boba-apple";

        aspects = [
          arc.base
          arc.mesh._.keys
        ];
      };

      den.hosts.x86_64-linux.pear = {
        users.kiki.key = "kiki-pear";
        users.boba.key = "boba-pear";

        aspects = [
          arc.base
          arc.mesh._.keys
        ];
      };

      den.hosts.aarch64-linux.orange = {
        users.kiki.key = "kiki-orange";
      };

      expr = {
        kiki = config.flake.darwinConfigurations.apple.config.users.users.kiki.openssh.authorizedKeys.keys;
        boba = config.flake.nixosConfigurations.pear.config.users.users.boba.openssh.authorizedKeys.keys;
      };

      expected = {
        boba = [
          "boba-apple"
          "boba-pear"
        ];
        kiki = [
          "kiki-orange"
          "kiki-pear"
        ];
      };
    }
  );
}
