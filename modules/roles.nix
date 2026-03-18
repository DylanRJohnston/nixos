{
  kit,
  den,
  lib,
  ...
}:
{
  kit.base.includes = [ kit.base.provides.zsh ];

  kit.schema.host = {
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

  kit.fuck.provides.host =
    { host }:
    { class, ... }:
    den.provides.forward {
      each = lib.unique host.roles or [ ];
      fromClass = _: class;
      intoClass = _: class;
      intoPath = _: [ ];
      fromAspect =
        role:
        lib.debug.traceSeq "HOST.provider (${class})->(${class}) role(${role})" den.lib.parametric.fixedTo {
          inherit host;
        } den.aspects.${role};
    };

  kit.fuck.provides.user =
    { host, user }:
    den.provides.forward {
      each = lib.cartesianProduct {
        role = lib.unique host.roles or [ ];
        class = [
          "os"
          host.class
        ];
      };
      fromClass = each: each.class;
      intoClass = _: host.class;
      intoPath = _: [ ];
      fromAspect =
        each:
        lib.debug.traceSeq "USER.provider (${each.class})->(${host.class}) role(${each.role})"
          den.lib.parametric.atLeast
          den.aspects.${each.role}
          { inherit host user; };
    };

  kit.fuck.provides.hm-user =
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
      fromAspect = role: den.lib.parametric.fixedTo { inherit host user; } den.aspects.${role};
    };
}
