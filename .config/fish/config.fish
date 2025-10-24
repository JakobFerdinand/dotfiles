if status is-interactive
    # Commands to run in interactive sessions can go here

    # VS Code
    set --export PATH /mnt/c/Users/Jakob.Wegenschimmel/AppData/Local/Programs/Microsoft\ VS\ Code/bin $PATH

    zoxide init fish | source

    # tmux
    set -gx TMUX_TMPDIR /tmp

    tmux attach
end
