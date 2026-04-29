let
  systemPackages =
    list:
    { pkgs, ... }:
    {
      environment.systemPackages = list pkgs;
    };

  systemCasks = casks: {
    homebrew.casks = casks;
  };

  packages.base.os =
    pkgs: with pkgs; [
      alejandra
      commitizen
      dix
      entr
      fd
      fzf
      git
      git-town
      gnupg
      htop
      iftop
      jq
      killall
      lsof
      mosh
      nix-output-monitor
      nix-tree
      nix-unit
      nixfmt
      pv
      sops
      tmux
      tree
      vim
      wget
      zstd
    ];

  packages.base.nixos =
    pkgs: with pkgs; [
      _1password-gui
      pulseaudio
    ];

  packages.base.casks = [
    "1password"
    "alfred"
    "caffeine"
    "dbeaver-community"
    "docker-desktop"
    "element"
    "firefox"
    "google-chrome"
    "istat-menus"
    "microsoft-teams"
    "obsidian"
    "omnifocus"
    "postman"
    "rectangle"
    "send-to-kindle"
    "wezterm"
    "wireshark-app"
    "zed"
  ];

  packages.entertainment.casks = [
    "audacity"
    "gimp"
    "signal"
    "slack"
    "spotify"
    "transmission"
    "vlc"
  ];

  packages.entertainment.nixos =
    pkgs: with pkgs; [
      audacity
      firefox
      gimp
      spotify
      vlc
    ];

  packages.development.os =
    pkgs: with pkgs; [
      awscli2
      binaryen
      cachix
      claude-code
      kubectl
      kubectx
      nixd
      nmap
      pandoc
    ];
in
{
  arc.base.os = systemPackages packages.base.os;
  arc.base.nixos = systemPackages packages.base.nixos;
  arc.base.darwin = systemCasks packages.base.casks;

  arc.development.os = systemPackages packages.development.os;

  arc.entertainment.nixos = systemPackages packages.entertainment.nixos;
  arc.entertainment.darwin = systemCasks packages.entertainment.casks;
  arc.entertainment.homeManager = {
    targets.darwin.copyApps.enable = false;
    targets.darwin.copyApps.enableChecks = false;
  };
}
