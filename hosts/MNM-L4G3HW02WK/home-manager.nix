{
  pkgs,
  common,
  lib,
  ...
}:
{
  imports = [ common.base ];

  home.packages = with pkgs; [
    awscli2
    binaryen
    kubectl
    kubectx
    nmap
  ];

  programs.git = {
    userName = lib.mkForce "Dylan Johnston";
    userEmail = lib.mkForce "dylan.johnston@cba.com.au";
  };

  programs.ssh.matchBlocks = {
    "github.com" = {
      hostname = lib.mkForce "ssh.github.com";
      port = 443;
      extraOptions = {
        AddKeysToAgent = "true";
        UseKeychain = "true";
      };
    };
    "personal.github.com" = {
      hostname = lib.mkForce "ssh.github.com";
      port = 443;
      extraOptions = {
        AddKeysToAgent = "true";
        UseKeychain = "true";
      };
    };
  };
}
