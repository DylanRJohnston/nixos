rec {
  imports = [ flake.flakeModule.arc ];
  flake.flakeModule.arc =
    { inputs, arc, ... }:
    let
      importing = inputs ? arc;
      import-namespace = inputs.den.namespace "arc" [ inputs.arc ];
      export-namespace = inputs.den.namespace "arc" true;
    in
    {
      imports = [
        inputs.den.flakeModule
        (if importing then import-namespace else export-namespace)
      ];

      den = { inherit (arc) ctx schema; };
    };
}
