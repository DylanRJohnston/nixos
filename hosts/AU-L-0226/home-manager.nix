{ pkgs, common, lib, ... }: {
  imports = with common; [
    base
  ];

  programs.git.extraConfig.commit.gpgsign = true;
  programs.git.userEmail = lib.mkForce "dylan.johnston@familyzone.com";
  programs.git.extraConfig.user.signingkey = "4BC9D5079C1C27983F0E51022CC94E7BF2C3D171";
}


