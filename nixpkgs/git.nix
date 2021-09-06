{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Dylan R. Johnston";
    userEmail = "dylan.r.johnston@gmail.com";
    aliases = {
      append = "town append";
      hack = "town hack";
      kill = "town kill";
      new-pull-request = "town new-pull-request";
      prune-branch = "town prune-branch";
      repo = "town repo";
      ship = "town ship";
      sync = "town sync";
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
}
