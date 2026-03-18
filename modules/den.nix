{
  inputs,
  lib,
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
  imports = [
    inputs.den.flakeModule
    inputs.flake-aspects.flakeModule
    (inputs.den.namespace "kit" true)
    hoistModule
  ];

  den.aspects = lib.debug.traceSeq (builtins.attrNames kit) {
    inherit (kit)
      base
      development
      gaming
      entertainment
      home-automation
      ;
  };

  den.ctx.host.includes = [ kit.fuck.provides.host ];
  den.ctx.user.includes = [ kit.fuck.provides.user ];
  den.ctx.hm-user.includes = [ kit.fuck.provides.hm-user ];
  den.schema.host = kit.schema.host;

  # flake.flakeModule = inputs.import-tree ../modules;
  flake.flakeModule = exportModule;
}
