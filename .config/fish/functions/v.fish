function v --description 'Open nvim, defaults to current directory'
    if set -q argv[1]
        nvim $argv
    else
        nvim .
    end
end
