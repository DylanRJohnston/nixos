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
    { arc, apple, ... }:
    {
      den.hosts.aarch64-darwin.apple = {
        users.tux = { };
        aspects = with arc; [ base ];
      };

      expr = apple.homebrew.onActivation.cleanup;
      expected = "zap";
    }
  );
}
