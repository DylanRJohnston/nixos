{ pkgs, ... }: with pkgs; {
  environment.systemPackages =
    [
      vim
      git
    ];
}