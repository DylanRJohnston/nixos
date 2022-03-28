{ config, pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./homebrew.nix
    ./touchID.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.vim
      pkgs.git
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";
  nixpkgs.config.allowUnfree = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.defaults.dock.show-recents = false;
  system.defaults.dock.autohide = true;


  system.defaults = {
    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleKeyboardUIMode = 3;

      "com.apple.sound.beep.feedback" = 0;

      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
    };
  };

}
