if status is-interactive
    # Commands to run in interactive sessions can go here

    # VS Code
    set --export PATH /mnt/c/Users/Jakob.Wegenschimmel/AppData/Local/Programs/Microsoft\ VS\ Code/bin $PATH

     if test -d $HOME/.dotnet/tools
         set -x PATH $PATH $HOME/.dotnet/tools
     end

    if test -e "$HOME/.dotnet/dotnet"
        set -x DOTNET_ROOT "$HOME/.dotnet/"
        set -x PATH $DOTNET_ROOT $PATH
    end
 
     zoxide init fish | source

    if is_wsl
        # Set up Kerberos credentials cache
        mkdir -p /tmp/krbcc/ccache/
        chmod 700 /tmp/krbcc
        set -x KRB5CCNAME DIR:/tmp/krbcc/ccache
    end

    # tmux
    set -gx TMUX_TMPDIR /tmp

    if not set -q TMUX
        if tmux ls >/dev/null 2>&1
            tmux attach
        else
            tmux new
        end
    end
end
