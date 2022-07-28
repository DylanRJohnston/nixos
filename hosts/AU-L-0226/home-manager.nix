{ pkgs, common, lib, ... }: {
  imports = with common; [
    base
  ];

  programs.git.extraConfig.commit.gpgsign = true;
  programs.git.userEmail = lib.mkForce "dylan.johnston@familyzone.com";
  programs.git.extraConfig.user.signingkey = "83B0853C309E5B1A88229F7060A49FA3602E67CE";
}


