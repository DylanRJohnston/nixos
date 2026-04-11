{ den, ... }:
{
  arc.schema.host =
    { host, lib, ... }:
    {
      options.primaryUser = lib.mkOption {
        type = lib.types.anything;
        default =
          if (host.users |> lib.attrNames |> lib.length) == 1 then
            host.users |> lib.attrValues |> lib.head
          else
            lib.warn "if there is more than one user, the host.primaryUser must be set" null;

      };
    };

  den.aspects.dylanj.includes = [
    den._.define-user
    den._.primary-user
    (den._.user-shell "zsh")
  ];
}
