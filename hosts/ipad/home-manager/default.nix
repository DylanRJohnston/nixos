{ pkgs, common, ... }: {
  imports = with common; [
    alacritty
    direnv
    git
    i3
    compton
    vim
    vscode
    zsh
    tmux
<<<<<<< Updated upstream
    home-manager
    gpg-agent
    packages
  ];
 }


=======
    packages
    home-manager
    wezterm
  ];

  programs.firefox.enable = true;
  programs.rofi.enable = true;

}
>>>>>>> Stashed changes
