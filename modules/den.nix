rec {
  imports = [ flake.flakeModule ];
  flake.flakeModule =
    { inputs, arc, ... }:
    let
      namespace =
        if (inputs ? arc) then
          inputs.den.namespace "arc" [ inputs.arc ]
        else
          inputs.den.namespace "arc" true;

    in
    {
      imports = [
        inputs.den.flakeModule
        namespace
      ];

      den.ctx.host.includes = [ arc.roles._.host ];
      den.ctx.user.includes = [ arc.roles._.user ];
      den.ctx.hm-user.includes = [ arc.roles._.homeManager ];

      den.schema.user.imports = [ arc.schema.user ];
      den.schema.host.imports = [ arc.schema.host ];
    };
}
