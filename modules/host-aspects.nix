{ lib, den, ... }:
let
  aspects =
    host:
    lib.cartesianProduct {
      aspect = host.aspects;
      class = [
        host.class
        "os"
      ];
    };

  host =
    { host }:
    den._.forward {
      each = aspects host;
      fromClass = it: it.class;
      intoClass = it: it.class;
      intoPath = _: [ ];
      fromAspect = it: den.lib.parametric.fixedTo { inherit host; } it.aspect;
    };

  user =
    { host, user }:
    den._.forward {
      each = host.aspects;
      fromClass = lib.const "user";
      intoClass = lib.const host.class;
      intoPath = _: [
        "users"
        "users"
        user.userName
      ];
      fromAspect = it: den.lib.parametric.fixedTo { inherit host user; } it;
    };

  homeManager =
    { host, user }:
    den._.forward {
      each = host.aspects;
      fromClass = lib.const "homeManager";
      intoClass = lib.const host.class;
      intoPath = _: [
        "home-manager"
        "users"
        user.userName
      ];
      fromAspect = it: den.lib.parametric.fixedTo { inherit host user; } it;
    };
in
{
  arc.ctx.host.includes = [ host ];
  arc.ctx.user.includes = [
    user
    homeManager
  ];
}
