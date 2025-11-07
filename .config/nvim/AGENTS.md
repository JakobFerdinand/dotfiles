# Agent Guidelines for Neovim Configuration

## Git Usage

This directory is part of a bare git repository managed via a `config` alias. Always use `config` instead of `git` for version control operations. If `config` is unavailable, fall back to:
```bash
git --git-dir="$HOME/dotfiles" --work-tree="$HOME"
```

Examples:
- `config status` instead of `git status`
- `config add file.lua` instead of `git add file.lua`
- `config commit -m "message"` instead of `git commit -m "message"`

## Build/Lint/Test Commands

### Formatting
- **Format Lua files**: `stylua .` (uses .stylua.toml config: 2-space indent, 160 column width, Unix line endings, auto-prefer single quotes)

### Linting
- **Lint files**: `:Lint` (nvim-lint plugin, configured for markdown with markdownlint)
- **Health check**: `:checkhealth` (verifies Neovim version and external dependencies)

### Testing
- **No traditional tests**: This is a Neovim configuration repository
- **Plugin verification**: `:Lazy` to check plugin status
- **Mason tools**: `:Mason` to verify installed LSP servers and tools

### Single Test/File Operations
- **Format single file**: `stylua path/to/file.lua`
- **Lint single file**: Open file and run `:Lint` (triggers on BufEnter/BufWritePost/InsertLeave)

## Code Style Guidelines

### Lua Formatting (.stylua.toml)
- Indent: 2 spaces
- Column width: 160 characters
- Line endings: Unix
- Quote style: Auto-prefer single quotes
- Call parentheses: None

### Neovim API Usage
- Use `vim.o` for simple option settings: `vim.o.number = true`
- Use `vim.opt` for table-based options: `vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }`
- Use `vim.keymap.set()` for keybindings with descriptive options
- Use `vim.api.nvim_create_autocmd()` and `vim.api.nvim_create_augroup()` for autocommands

### Plugin Configuration Pattern
```lua
{
  'plugin/name',
  opts = {
    -- Configuration options
  },
  config = function()
    -- Setup code
  end,
}
```

### Error Handling
- Use `pcall()` for operations that might fail: `local ok, result = pcall(vim.fn.readfile, path)`
- Check return values before using: `if not ok then return nil end`

### Naming Conventions
- Functions: camelCase for local functions, snake_case for API functions
- Variables: snake_case
- Constants: UPPER_CASE
- Use descriptive names with full words rather than abbreviations

### Imports and Dependencies
- Require modules at function start: `local module = require 'module.name'`
- Use local variables for frequently accessed modules
- Prefer single quotes for strings unless containing single quotes

### Comments and Documentation
- Use `--` for single-line comments
- Use `--[[ ]]` for multi-line comments
- Document complex logic and non-obvious code
- Include `:help` references for Neovim-specific features</content>
<parameter name="filePath">AGENTS.md