{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    _1password-gui
  ];
}
