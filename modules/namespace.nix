let
  module =
    {
      inputs,
      arc,
      lib,
      ...
    }:
    let
      importing = inputs ? arc;
      import-namespace = inputs.den.namespace "arc" [ inputs.arc ];
      export-namespace = inputs.den.namespace "arc" true;
    in
    {
      imports = [
        inputs.den.flakeModule
        inputs.den.flakeModules.strict
        inputs.den.flakeOutputs.all
        (if importing then import-namespace else export-namespace)
      ];

      options.flake.flakeModule = lib.mkOption {
        type = lib.types.deferredModule;
      };

      options.flake.flakeModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.deferredModule;
      };

      config.den = { inherit (arc) ctx schema; };
    };
in
{
  imports = [ module ];
  flake.flakeModule = module;
}
