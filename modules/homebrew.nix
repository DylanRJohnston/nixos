{ arc, unitTest, ... }:
{
  arc.base.includes = [ arc.base._.homebrew ];
  arc.base._.homebrew.darwin =
    { config, ... }:
    {
      homebrew = {
        enable = true;
        user = config.system.primaryUser;
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
      };
    };

  flake.tests.homebrew.test-cleanup = unitTest (
    { arc, igloo, ... }:
    {
      den.hosts.aarch64-darwin.igloo = {
        user.tux = { };
        aspects = with arc; [ base ];
      };

      expr = igloo.homebrew.onActivation.cleanup;
      expected = "zap";
    }
  );
}
