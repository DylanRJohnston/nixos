{ pkgs, common, ... }: {
  imports = with common; [
    base
  ];

  programs.firefox.enable = true;
}
