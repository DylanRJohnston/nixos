{
  inputs,
  lib,
  den,
  kit,
  ...
}:
let
  hoistModule =
    { kit, ... }:
    {
    };

  importModule =
    { inputs, ... }:
    {
      imports = [ (inputs.den.namespace "kit" [ inputs.kit ]) ];
    };

  exportModule.imports = [
    importModule
    hoistModule
  ];
in
{
  _module.args.__findFile = den.lib.__findFile;

  imports = [
    inputs.den.flakeModule
    inputs.flake-aspects.flakeModule
    (inputs.den.namespace "kit" true)
    hoistModule
  ];

  den.ctx.host.includes = [
    (
      { host }:
      {
        includes = host.includes;
      }
    )
  ];

  den.ctx.hm-user.includes = [
    (
      { host, user }:
      {
        includes = host.includes;
      }
    )
  ];

  # den.ctx.host.includes = [ kit.fuck.provides.host ];
  # den.ctx.user.includes = [ kit.fuck.provides.user ];
  # den.ctx.hm-user.includes = [ kit.fuck.provides.hm-user ];
  # den.schema.host = kit.schema.host;
  den.schema.user = kit.schema.user;

  # flake.flakeModule = inputs.import-tree ../modules;
  flake.flakeModule = exportModule;
}
