{
  arc.base.os =
    { pkgs, ... }:
    {
      fonts = {
        packages = [ pkgs.nerd-fonts.fira-code ];
      };
    };
}
