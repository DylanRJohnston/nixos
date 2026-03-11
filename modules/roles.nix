{ den, ... }:
{
  den.ctx.host.includes = [
    (
      { host }:
      { class, ... }:
      den.provides.forward {
        each = host.roles;
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
        each = host.roles;
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
