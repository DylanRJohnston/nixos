{ lib, den, ... }:
let
  recursiveApply =
    apply: ctx: include:
    if include ? includes then recursiveFunctor apply include ctx else apply ctx include;

  recursiveFunctor =
    apply: aspect:
    aspect
    // {
      __functor = self: ctx: {
        includes =
          self.includes or [ ]
          |> builtins.filter lib.isFunction
          |> map (recursiveApply apply ctx)
          |> builtins.filter (x: x != { });
      };
    };

  parametric.fixedTo.exactly =
    ctx: aspect: recursiveFunctor (lib.flip den.lib.take.exactly) aspect ctx;

  parametric.fixedTo.atLeast =
    ctx: aspect: recursiveFunctor (lib.flip den.lib.take.atLeast) aspect ctx;
in
{
  arc.schema.host.options.aspects = lib.mkOption {
    type = lib.types.listOf den.lib.aspects.types.aspectSubmodule;
  };

  arc.aspects._.host.includes = [
    (
      { host }:
      den.lib.parametric.fixedTo { inherit host; } {
        includes = host.aspects;
      }
    )
  ];

  arc.aspects._.homeManager.includes = [
    (
      { host, user }:
      { class, ... }:
      if class == "homeManager" then
        den.lib.parametric.fixedTo { inherit host user; } {
          includes = host.aspects;
        }
      else
        { }
    )
  ];

  arc.aspects._.user.includes = [
    (
      { host, user }:
      parametric.fixedTo.atLeast { inherit host user; } {
        includes = host.aspects;
      }
    )
  ];
}
