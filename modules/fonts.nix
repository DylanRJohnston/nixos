{
  den.aspects.base.os =
    { pkgs, ... }:
    {
      fonts = {
        packages = [ pkgs.nerd-fonts.fira-code ];
      };
    };
}
