{ lib, ... }:
rec {
  imports = [ flake.flakeModule ];
  flake.flakeModule =
    { inputs, kit, ... }:
    let
      namespace =
        if (inputs ? kit) then
          inputs.den.namespace "kit" [ inputs.kit ]
        else
          inputs.den.namespace "kit" true;

    in
    {
      imports = [
        inputs.den.flakeModule
        namespace
      ];

      den.ctx.host.includes = [ kit.roles._.host ];
      den.ctx.user.includes = [ kit.roles._.user ];
      den.ctx.hm-user.includes = [ kit.roles._.homeManager ];

      den.schema.user.imports = [ kit.schema.user ];
      den.schema.host.imports = [ kit.schema.host ];
    };
}
