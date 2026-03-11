{ ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    sensibleOnTop = true;
    terminal = "screen-256color";

    baseIndex = 1;
    extraConfig = ''
      set -g pane-base-index 1
      set -g renumber-windows on
      set -g detach-on-destroy off
      set -g status-position bottom

      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
      set -g message-style "bg=#89b4fa,fg=#1e1e2e"
      set -g message-command-style "bg=#89b4fa,fg=#1e1e2e"
      set -g pane-border-style "fg=#45475a"
      set -g pane-active-border-style "fg=#89b4fa"

      set -g status-left-length 30
      set -g status-right-length 100
      set -g status-left "#[fg=#1e1e2e,bg=#89b4fa,bold] #S #[fg=#89b4fa,bg=#1e1e2e]█#[default]"
      set -g status-right "#[fg=#a6e3a1]#(whoami) #[fg=#6c7086]| #[fg=#94e2d5]%a %d %b #[fg=#f9e2af]%H:%M "

      setw -g window-status-format "#[fg=#bac2de,bg=#313244] #I:#W "
      setw -g window-status-current-format "#[fg=#1e1e2e,bg=#a6e3a1,bold] #I:#W "
      setw -g window-status-style "fg=#bac2de,bg=#313244"
    '';
  };
}
