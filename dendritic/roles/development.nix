{
  flake.modules.homeManager.development =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        awscli2
        binaryen
        kubectl
        kubectx
        nmap
      ];

      custom.nushell.enable = true;
    };
}
