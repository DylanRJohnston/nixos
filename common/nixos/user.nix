{ pkgs, ... }: {
  programs.zsh.enable = true;

  users = {
    mutableUsers = false;
    users.dylanj = {
      isNormalUser = true;
      home = "/home/dylanj";
      shell = pkgs.zsh;
      initialHashedPassword = "$6$0GbKVmhif9YzlbwF$qSrltRk9zeozVzXG4RFa.Hl5z4RakDG4rIO1DrzRd/zJEIX06/eUlgxNWtRbPMgA0tvM0gxwgTSTA5WWJYuUB.";
      extraGroups = [ "wheel" "networkmanager" "audio" "docker" ];
    };
  };
}
