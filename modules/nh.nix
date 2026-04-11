{ arc, den, ... }:
{
  arc.base.includes = [ arc.base._.nh ];

  arc.base._.nh = den.lib.perHost (
    { host }:
    {
      os =
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.nh ];
          environment.variables.NH_FLAKE = host.flake;
        };

      nixos.programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
      };
    }
  );
}
