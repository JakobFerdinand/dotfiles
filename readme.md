# Dotfiles

Dotfiles are the configuration files for various tools and programs.
Most of them start with a `.` - that´s why they are called `dotfiles`.

## How to managed dotfiles

I use a **git bare repository** to manage my dotfiles.  
I found the idea on [Derek Taylor´s Youtube Channel](https://www.youtube.com/watch?v=tBoLDpTWVOM&t=905s). His [GitLab](https://gitlab.com/dwt1/dotfiles) page is also a great resource for configuration ideas.

## Zsh Configuration

For using all tools and options configured in the `zsh configuration` some tools are needen.

### Go
Go mainly is needed to install other tools.

**MacOS**
```bash
brew install go
```

### Chroma
[`Chroma`](https://github.com/alecthomas/chroma) is a general purpose syntax highlither.  
It´s used by the `ccat` tool.
```go
go get -u github.com/alecthomas/chroma/cmd/chroma
```
