{
  flake.modules.darwin.base =
    { pkgs, ... }:
    {
      programs.zsh.enable = true;

      environment.systemPackages = [
        pkgs.vim
        pkgs.git
        pkgs.nixd
      ];
    };
}
