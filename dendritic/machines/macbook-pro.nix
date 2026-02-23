{
  configurations.darwin.macbook-pro = {
    system = "aarch64-darwin";

    roles = [
      "base"
      "development"
      "entertainment"
      "gaming"
    ];

    module = {
      homebrew.casks = [
        "backblaze"
      ];
    };

    homeManager =
      { pkgs, ... }:
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
      };
  };
}
