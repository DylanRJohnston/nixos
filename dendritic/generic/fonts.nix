{
  flake.modules.generic.base =
    { pkgs, ... }:
    {
      fonts = {
        packages = [ pkgs.nerd-fonts.fira-code ];
      };
    };
}
