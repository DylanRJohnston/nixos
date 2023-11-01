{ pkgs, ... }: {
  programs.zsh.enable = true;

  users = {
    mutableUsers = false;
    users.dylanj = {
      isNormalUser = true;
      home = "/home/dylanj";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" "audio" "docker" ];
    };
  };
}
