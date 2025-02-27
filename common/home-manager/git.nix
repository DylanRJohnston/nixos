{ lib, ... }:
let
  git-town-aliases = lib.genAttrs [
    "append"
    "hack"
    "delete"
    "new-pull-request"
    "prepend"
    "append"
    "prune-branch"
    "repo"
    "ship"
    "sync"
  ] (name: "town ${name}");
in
{
  programs.git = {
    enable = true;
    userName = "Dylan R. Johnston";
    userEmail = "dylan.r.johnston@gmail.com";
    aliases = git-town-aliases;
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "vim";
      push.default = "current";
      merge.conflictstyle = "diff3";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
