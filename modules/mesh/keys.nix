let
  # Needs to be deferred because we want den.hosts to be at the import site
  deferredModule =
    {
      den,
      arc,
      lib,
      ...
    }:
    {
      arc.mesh.includes = [ arc.mesh._.keys ];

      arc.mesh._.keys.os.users.users =
        let
          hosts =
            den.hosts # nixfmt
            |> lib.attrValues
            |> lib.map lib.attrValues
            |> lib.flatten;

          host_keys = hosts |> lib.map (it: it.hostKey);

          user_keys =
            hosts
            |> lib.map (it: it.users)
            |> lib.map lib.attrValues
            |> lib.flatten
            |> lib.groupBy' (acc: it: acc ++ [ it.key ]) [ ] (it: it.userName);

          all_keys =
            user_keys # nixfmt
            |> lib.mapAttrs (_: lib.flip lib.concat host_keys)
            |> lib.mapAttrs (_: lib.filter (it: it != null));
        in
        all_keys |> lib.mapAttrs (_: keys: { openssh.authorizedKeys.keys = keys; });
    };
in
{ lib, unitTest, ... }:
{
  imports = [ deferredModule ];
  flake.flakeModule = deferredModule;

  arc.schema.user.options.key = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "SSH public key";
  };

  arc.schema.host.options.hostKey = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "SSH public host key";
  };

  flake.tests.mesh = {
    test-cross-host-user-keys = unitTest (
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

    test-cross-host-host-keys = unitTest (
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
          hostKey = "orange-host-key";
        };

        expr = {
          apple-kiki =
            config.flake.darwinConfigurations.apple.config.users.users.kiki.openssh.authorizedKeys.keys;
          pear-boba =
            config.flake.nixosConfigurations.pear.config.users.users.boba.openssh.authorizedKeys.keys;
        };

        expected = {
          pear-boba = [
            "boba-apple"
            "boba-pear"
            "orange-host-key"
          ];
          apple-kiki = [
            "kiki-orange"
            "kiki-pear"
            "orange-host-key"
          ];
        };
      }
    );
  };
}
