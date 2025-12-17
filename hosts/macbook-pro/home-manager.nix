{
  pkgs,
  ...
}:
{
  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "desktop" = {
      hostname = "dylan-desktop.local";
      user = "dylanj";
    };
  };

  home.packages = with pkgs; [
    awscli2
    binaryen
    ffmpeg
    inkscape
    kubectl
    kubectx
    nmap
    openvpn
  ];
}
