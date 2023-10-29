{ pkgs, ... }: with pkgs; {
  programs.zsh.enable = true;
  environment.systemPackages =
    [
      vim
      git
      nil
    ];
}
