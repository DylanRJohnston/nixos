{ lib, ... }:
let
  git-town-aliases = lib.genAttrs
    [
      "append"
      "hack"
      "kill"
      "new-pull-request"
      "prepend"
      "append"
      "prune-branch"
      "repo"
      "ship"
      "sync"
    ]
    (name: "town ${name}");
in
{
  programs.git = {
    enable = true;
    userName = "Dylan R. Johnston";
    userEmail = "dylan.r.johnston@gmail.com";
    aliases = git-town-aliases;
    extraConfig = {
      commit.gpgsign = true;
      init.defaultBranch = "main";
      core.editor = "vim";
      push.default = "current";
      merge.conflictstyle = "diff3";
    };
  };
}
