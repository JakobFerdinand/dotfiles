function is_wsl --description 'Return success if running inside Windows Subsystem for Linux'
    if test -f /proc/version
        if string match -q "*-microsoft-standard-WSL*" (cat /proc/version)
            return 0
        end
    end
    return 1
end
