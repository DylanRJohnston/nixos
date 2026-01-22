{ lib, config, ... }:
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
  options = {
    custom.git.enable = lib.mkEnableOption "Enable git";
  };

  config.programs.git = lib.mkIf config.custom.git.enable {
    enable = true;
    settings = {
      user.name = "Dylan R. Johnston";
      user.email = "dylan.r.johnston@gmail.com";

      alias = git-town-aliases;

      init.defaultBranch = "main";
      core.editor = "vim";
      push.default = "current";
      merge.conflictstyle = "diff3";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
