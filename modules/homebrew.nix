{ arc, ... }:
{
  arc.base.includes = [ arc.base._.homebrew ];
  arc.base._.homebrew =
    { user, ... }:
    {
      darwin.homebrew = {
        enable = true;
        user = user.userName;
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
      };
    };
}
