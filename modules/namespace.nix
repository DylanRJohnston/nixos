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
      # Upstream exports navigation aliases alongside provides. Re-import only
      # definitions: strict mode rejects those aliases as undeclared options.
      import-namespace = inputs.den.namespace "arc" [
        (
          inputs.arc
          // {
            denful.arc = lib.mapAttrs (
              _: value:
              if builtins.isAttrs value then
                builtins.removeAttrs value ((value.__providesForwarded or [ ]) ++ [ "__providesForwarded" ])
              else
                value
            ) inputs.arc.denful.arc;
          }
        )
      ];
      export-namespace = inputs.den.namespace "arc" true;
    in
    {
      imports = [
        inputs.den.flakeModule
        inputs.den.flakeModules.strict
        (if importing then import-namespace else export-namespace)
      ]
      ++ inputs.den.flakeOutputs.all.includes;

      options.flake.flakeModule = lib.mkOption {
        type = lib.types.deferredModule;
      };

      options.flake.flakeModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.deferredModule;
      };

      config.den.schema = {
        inherit (arc.schema) host user;
        aspect.options =
          lib.genAttrs
            [
              "nixos"
              "darwin"
              "os"
              "user"
              "homeManager"
            ]
            (
              _:
              lib.mkOption {
                type = lib.types.deferredModule;
                default = { };
              }
            );
      };
    };
in
{
  imports = [ module ];
  flake.flakeModule = module;
}
