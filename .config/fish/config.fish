if status is-interactive
  # Commands to run in interactive sessions can go here

  # tmux
  set -gx TMUX_TMPDIR /tmp

  # bun
  set --export BUN_INSTALL "$HOME/.bun"
  set --export PATH $BUN_INSTALL/bin $PATH

  # VS Code
  set --export PATH /mnt/c/Users/Jakob.Wegenschimmel/AppData/Local/Programs/Microsoft\ VS\ Code/bin $PATH

  tmux
end
