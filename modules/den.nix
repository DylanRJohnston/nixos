{ den, lib, ... }:
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
        inputs.flake-aspects.flakeModule
        namespace
      ];

      kit.roles =
        { host, ... }:
        {
          includes = host.roles;
        };

      den.ctx.host.includes = [ kit.roles ];
      den.ctx.user.includes = [ kit.roles ];

      den.schema.user.imports = [ kit.schema.user ];
      den.schema.host.imports = [ kit.schema.host ];
    };
}
