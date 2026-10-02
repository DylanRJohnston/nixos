let
  module =
    { lib, den, ... }:
    {
      den.schema.user = {
        includes = [ den.batteries.host-aspects ];
        config.classes = lib.mkDefault [
          "user"
          "homeManager"
        ];
      };
    };
in
{
  imports = [ module ];
  flake.flakeModule = module;
}
