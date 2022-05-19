{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-window-option -g mouse on

      set-window-option -g mode-keys vi

      set -g history-limit 10000
      set-option -g base-index 1
      setw -g pane-base-index 1
      set-option -g renumber-windows on

      bind -n C-k clear-history
      set-option -g repeat-time 0

      bind m \
          set -g mouse on \;\
          display 'Mouse: ON'

      bind M \
          set -g mouse off \;\
          display 'Mouse: OFF'

      set -g default-terminal "xterm-256color"

      set -g pane-border-style fg=colour238
      set -g pane-active-border-style fg=colour245

      set -g status-style bg=colour0,fg=colour235

      set -g message-style bg=colour245,fg=colour0

      set -g status-interval 60

      set -g status-left '#[fg=colour0,bg=colour245] #S #[fg=colour245,bg=colour0]'
      set -g status-right '#[fg=colour245, bg=colour0]#[fg=colour0, bg=colour245] %H:%M #[fg=colour245, bg=colour0]#[fg=colour0, bg=colour245] %d/%m '

      set-window-option -g window-status-current-format "#[fg=colour0, bg=colour4]#[fg=colour0, bg=colour4] #I #{?window_zoomed_flag,#[fg=colour4 bg=colour255]#[fg=colour0 bg=colour4]#[fg=colour255 bg=colour4]#[fg=colour0 bg=colour4],} #W #[fg=colour4, bg=colour0]"
      set-window-option -g window-status-format "#[fg=colour0, bg=colour245] #I  #W #[fg=colour245, bg=0]"
    '';
  };
}
