let
  systemPackages =
    list:
    { pkgs, ... }:
    {
      environment.systemPackages = list pkgs;
    };

  systemCasks = casks: {
    homebrew.enable = true;
    homebrew.onActivation.cleanup = "zap";
    homebrew.onActivation.autoUpdate = true;
    homebrew.casks = casks;

    homeManager = {
      targets.darwin.copyApps.enable = false;
      targets.darwin.copyApps.enableChecks = false;
    };
  };

  packages.base.os =
    pkgs: with pkgs; [
      alejandra
      commitizen
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
    "firefox"
    "google-chrome"
    "istat-menus"
    "microsoft-teams"
    "obsidian"
    "omnifocus"
    "postman"
    "rectangle"
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
    ];
in
{
  arc.base.os = systemPackages packages.base.os;
  arc.base.nixos = systemPackages packages.base.nixos;
  arc.base.darwin = systemCasks packages.base.casks;

  arc.development.os = systemPackages packages.development.os;

  arc.entertainment.nixos = systemPackages packages.entertainment.nixos;
  arc.entertainment.darwin = systemCasks packages.entertainment.casks;
}
