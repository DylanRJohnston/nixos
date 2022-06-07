{ pkgs, ... }: {
  users = {
    mutableUsers = false;
    users.dylanj = {
      isNormalUser = true;
      home = "/home/dylanj";
      shell = pkgs.zsh;
      initialHashedPassword = "$6$0GbKVmhif9YzlbwF$qSrltRk9zeozVzXG4RFa.Hl5z4RakDG4rIO1DrzRd/zJEIX06/eUlgxNWtRbPMgA0tvM0gxwgTSTA5WWJYuUB.";
      extraGroups = [ "wheel" "networkmanager" "audio" "docker" ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfCS+gbhMJhdYjb2Wuc9HWCXc20kHkeg/GehsqqFBbe dylanjohnston@AU-L-0226.local"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyzdqghQdawsL7OPJZTCvsxjezGy8ZeemUoEhvjV47k pro@ipad"
      ];
    };

  };
}
