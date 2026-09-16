Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Ensure Posh-git is installed.
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
#
# Lazy-load: posh-git's own prompt gets overwritten by starship below anyway,
# so importing it at startup only buys git tab-completion. Defer the ~470ms
# Import-Module cost to the first Tab-press after "git "/"tgit "/"gitk "
# instead of paying it on every shell startup.
Register-ArgumentCompleter -Native -CommandName git, tgit, gitk -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    Import-Module posh-git
    (TabExpansion2 $commandAst.ToString() $cursorPosition).CompletionMatches
}

# Ensure Starship is installed.
# https://starship.rs/
# Cache the generated init script; only regenerate when starship.exe is newer
# than the cache (spawning starship.exe + Invoke-Expression every session was
# costing ~225ms of shell startup time).
$starshipCacheDir = "$env:LOCALAPPDATA\pwsh-cache"
$starshipCache = Join-Path $starshipCacheDir 'starship_init.ps1'
$starshipExe = (Get-Command starship -ErrorAction SilentlyContinue).Source
if ($starshipExe) {
    if (-not (Test-Path $starshipCache) -or (Get-Item $starshipExe).LastWriteTime -gt (Get-Item $starshipCache).LastWriteTime) {
        New-Item -ItemType Directory -Force -Path $starshipCacheDir | Out-Null
        # --print-full-init: `starship init powershell` alone just emits a stub
        # that re-invokes starship.exe every session; this gives the real script.
        & starship init powershell --print-full-init | Set-Content -Path $starshipCache -Encoding utf8
    }
    . $starshipCache
}

# Ensure Nvim is installed.
# https://github.com/neovim/neovim
Set-Alias vim nvim
$userHome = [Environment]::GetFolderPath('UserProfile')
$env:HOME = $userHome
$env:HOMEDRIVE = [IO.Path]::GetPathRoot($userHome).TrimEnd('\')
$env:HOMEPATH = $userHome.Substring($env:HOMEDRIVE.Length)

$localBinPath = Join-Path $userHome '.local\bin'
if ($localBinPath -notin ($env:PATH -split ';')) {
    $env:PATH = "$localBinPath;$env:PATH"
}

# Load bin's config and put all relevant dirs on PATH (per session)
$cfgPath = "$HOME\.config\bin\config.json"
if (Test-Path $cfgPath) {
    $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json

    # Collect candidate directories: default_path + each tool's directory
    $candidates =
        @($cfg.default_path) +
        ($cfg.bins.PSObject.Properties.Value |
            ForEach-Object { Split-Path -Path $_.path -Parent })

    $existingDirs = $candidates |
        Where-Object { $_ } |
        ForEach-Object { $_.Trim() } |
        Where-Object { Test-Path $_ } |
        Select-Object -Unique

    $current = $env:PATH -split ';'
    foreach ($dir in $existingDirs) {
        if (-not ($current | Where-Object { $_ -ieq $dir })) {
            $env:PATH = "$dir;$env:PATH"
        }
    }
}

function config {
    git.exe --git-dir=$HOME/dotfiles --work-tree=$HOME $args
}
function lazyconfig {
    lazygit -g $HOME/dotfiles -w $HOME @args
}
function lc {
    lazyconfig @args
}
function ghs {
    gh auth switch @args
}
function v {
    if ($args) {
        nvim @args
    } else {
        nvim .
    }
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function getVSDir {
    param (
        [bool]$preview
    )

    $prefix = "C:\Program Files\Microsoft Visual Studio\18\"
    $postfix = "\Common7\IDE\"

    if ($preview -eq 1 -and (Test-Path ($prefix + "Preview" + $postfix))) {
        return $prefix + "Preview" + $postfix;
    }
    elseif (Test-Path ($prefix + "Enterprise" + $postfix)) {
        return $prefix + "Enterprise" + $postfix;
    }
    elseif (Test-Path ($prefix + "Professional" + $postfix)) {
        return $prefix + "Professional" + $postfix;
    }
    elseif (Test-Path ($prefix + "Community" + $postfix)) {
        Set-Alias tf ($prefix + "Community" + $postfix)
    }
}

$vsDir = getVSDir -preview 0
$vsPreviewDir = getVSDir -preview 1

Set-Alias tf ($vsDir + "CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe")
Set-Alias vs ($vsDir + "devenv.exe")
Set-Alias vspreview ($vsPreviewDir + "devenv.exe")

Set-Alias lg lazygit

Set-Alias nuget "C:\Tools\nuget.exe"
Set-Alias speedtest "C:\Tools\speedtest.exe"
Set-Alias infosys "C:\tools\Infosys\Infosystem.lnk"
Set-Alias lamdera "C:\tools\lamdera\lamdera.exe"

function defenderScan {
  Start-MpScan -ScanType FullScan
}

function gitcleanup {
    Get-ChildItem -Recurse -Filter '*.orig' | Remove-Item
}

if (Test-Path Alias:ls) {
    Remove-Item Alias:ls
}
function ls {
    eza --icons -a -l --group-directories-first --no-permissions --no-time --ignore-glob=".git|dotfiles" $args
}

if (Test-Path Alias:cat) {
    Remove-Item Alias:cat
}
function cat {
    bat --paging=never $args
}

# Cache zoxide's init script the same way as starship above.
$zoxideCacheDir = "$env:LOCALAPPDATA\pwsh-cache"
$zoxideCache = Join-Path $zoxideCacheDir 'zoxide_init.ps1'
$zoxideExe = (Get-Command zoxide -ErrorAction SilentlyContinue).Source
if ($zoxideExe) {
    if (-not (Test-Path $zoxideCache) -or (Get-Item $zoxideExe).LastWriteTime -gt (Get-Item $zoxideCache).LastWriteTime) {
        New-Item -ItemType Directory -Force -Path $zoxideCacheDir | Out-Null
        zoxide init powershell | Set-Content -Path $zoxideCache -Encoding utf8
    }
    . $zoxideCache
}

# yazi wrapper to change working directory after command execution
if (Get-Command yazi.exe -ErrorAction SilentlyContinue) {
	function y {
		$tmp = (New-TemporaryFile).FullName
		yazi.exe @args --cwd-file="$tmp"
		$cwd = Get-Content -Path $tmp -Encoding UTF8
		if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
			Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
		}
		Remove-Item -Path $tmp
	}

	# Ensure yazi can find file.exe if git is installed in localappdata
	$fileExe = "$env:LOCALAPPDATA\Programs\Git\usr\bin\file.exe"
	if (Test-Path $fileExe) {
		$env:YAZI_FILE_ONE = $fileExe
		if ([Environment]::GetEnvironmentVariable("YAZI_FILE_ONE", "User") -ne $fileExe) {
			[Environment]::SetEnvironmentVariable(
				"YAZI_FILE_ONE",
				$fileExe,
				"User"
			)
		}
	}

    $yaziConfigHome = "$HOME\.config\yazi"
    if ([Environment]::GetEnvironmentVariable("YAZI_CONFIG_HOME", "User") -ne $yaziConfigHome) {
        [Environment]::SetEnvironmentVariable(
            "YAZI_CONFIG_HOME",
            $yaziConfigHome,
            "User"
        )
    }
}

if (Get-Command herdr -ErrorAction SilentlyContinue) {
    $env:HERDR_CONFIG_PATH = "$HOME\.config\herdr\config.windows.toml"
}
