{ pkgs, ... }: {
  users.users.dylanj = {
    isNormalUser = true;
    home = "/home/dylanj";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
  };
}
