{ lib, osConfig, ... }:
{
  config = lib.mkIf (builtins.elem "base" osConfig.custom.roles) {
    custom = {
      direnv.enable = true;
      git.enable = true;
      packages.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      vim.enable = true;
      vscode.enable = true;
      wezterm.enable = true;
      zed.enable = true;
      zsh.enable = true;
    };
  };
}
