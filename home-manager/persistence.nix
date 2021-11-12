{
  home.persistence."/nix/persist/home/dylanj" = {
    directories = [
      "Downloads"
      "Pictures"
      ".ssh"
      "Workspace"
    ];
    files = [
      ".zsh_history"
    ];
  };
}
