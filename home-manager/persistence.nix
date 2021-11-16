{
  home.persistence."/nix/persist/home/dylanj" = {
    allowOther = false;

    directories = [
      "Downloads"
      "Pictures"
      ".ssh"
      "Workspace"
      ".config/1Password"
      ".enhancd"
      ".mozilla"
      ".config/spotify"
      ".local/share/direnv"
    ];
    files = [
      ".zsh_history"
      ".cache/rofi-3.runcache"
    ];
  };
}
