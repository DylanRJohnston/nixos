{ den, lib, ... }:
{
  den.schema.host = {
    options.roles = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "base"
          "development"
          "entertainment"
          "gaming"
          "home-automation"
        ]
      );
    };

    config.roles = [ "base" ];
  };

  den.ctx.host.includes = [
    (
      { host }:
      { class, ... }:
      den.provides.forward {
        each = lib.unique host.roles or [ ];
        fromClass = _: class;
        intoClass = _: class;
        intoPath = _: [ ];
        fromAspect = role: den.aspects.${role};
      }
    )
  ];

  den.ctx.hm-user.includes = [
    (
      { host, user }:
      den.provides.forward {
        each = lib.unique host.roles or [ ];
        fromClass = _: "homeManager";
        intoClass = _: host.class;
        intoPath = _: [
          "home-manager"
          "users"
          user.userName
        ];
        fromAspect = role: den.aspects.${role};
      }
    )
  ];
}
