# Neovim Configuration Restructuring Plan

## Current State
- **init.lua**: 255 lines (reduced from 1030) with leader key, nerd font setup, config requires, and plugin loader
- **lua/config/**: ✓ NEW - Core configuration modules (settings.lua, keymaps.lua, autocommands.lua)
- **lua/kickstart/plugins/**: Optional plugins with individual configs (debug ✓ REMOVED, gitsigns, autopairs, neo-tree, lint, indent_line)
- **lua/custom/plugins/**: Custom plugins (trouble, roslyn, ✓ dap moved to lua/plugins/, lazygit) + init.lua with vim-tmux-navigator
- **lua/plugins/**: ✓ dap-core.lua (shared DAP infrastructure), dap-csharp.lua (C#/.NET debugging)

## Goal
Restructure to have **one plugin configuration file per plugin** with meaningful names. Each plugin should be independently managed and clearly organized.

## Proposed Directory Structure

```
~/.config/nvim/
├── init.lua                              # Leader key, nerd font, config requires, lazy setup (minimal ~80-100 lines)
├── lua/
│   ├── config/                           # ✓ DONE: Core configuration modules
│   │   ├── settings.lua                  # Editor options (indentation, line numbers, etc.)
│   │   ├── keymaps.lua                   # Global keymaps (split navigation, search, etc.)
│   │   └── autocommands.lua              # Global autocommands (yank highlight, etc.)
│   ├── plugins/                          # Consolidated plugins directory
│   │   ├── guess-indent.lua              # guess-indent.nvim
│   │   ├── gitsigns.lua                  # lewis6991/gitsigns.nvim
│   │   ├── which-key.lua                 # folke/which-key.nvim
│   │   ├── telescope.lua                 # nvim-telescope/telescope.nvim + dependencies
│   │   ├── lazydev.lua                   # folke/lazydev.nvim
│   │   ├── lspconfig.lua                 # neovim/nvim-lspconfig + mason setup
│   │   ├── conform.lua                   # stevearc/conform.nvim (autoformat)
│   │   ├── blink-cmp.lua                 # saghen/blink.cmp (completion)
│   │   ├── tokyonight.lua                # folke/tokyonight.nvim (colorscheme)
│   │   ├── todo-comments.lua             # folke/todo-comments.nvim
│   │   ├── mini.lua                      # echasnovski/mini.nvim (ai, surround, statusline)
│   │   ├── treesitter.lua                # nvim-treesitter/nvim-treesitter
│   │   ├── neo-tree.lua                  # nvim-neo-tree/neo-tree.nvim (file browser)
│   │   ├── gitsigns.lua                  # gitsigns keymaps (moved from kickstart)
│   │   ├── indent-line.lua               # lukas-reineke/indent-blankline.nvim
│   │   ├── autopairs.lua                 # windwp/nvim-autopairs
│   │   ├── lint.lua                      # mfussenegger/nvim-lint
│   │   ├── dap-core.lua                  # ✓ DONE: mfussenegger/nvim-dap (shared infrastructure)
│   │   ├── dap-csharp.lua                # ✓ DONE: C#/.NET debugging with netcoredbg
│   │   ├── trouble.lua                   # folke/trouble.nvim (diagnostics)
│   │   ├── roslyn.lua                    # Custom: roslyn LSP configuration for C#
│   │   ├── lazygit.lua                   # Custom: lazygit integration
│   │   ├── tmux-navigator.lua            # christoomey/vim-tmux-navigator
│   │   └── init.lua                      # Plugin loader (imports all above)
│   └── kickstart/                        # DEPRECATED: Keep only for health check
│       └── health.lua
└── .stylua.toml                          # Formatting config
```

## Migration Steps

### Phase 1: Create Core Configuration Modules

✓ **DONE** - Completed:
1. Created `lua/config/settings.lua` - All vim.o and vim.opt settings
2. Created `lua/config/keymaps.lua` - All global keymaps
3. Created `lua/config/autocommands.lua` - Global autocommands
4. Updated init.lua to require core config modules
5. Tested configuration loads correctly
6. Committed changes

**Files created:** 3 new config modules
**init.lua size:** Reduced from 1030 → 255 lines (75% reduction in this section)

### Phase 2: Extract Inline Plugin Configurations

4. **Inline plugins in init.lua → individual files in `lua/plugins/`**
   - `guess-indent.lua`: guess-indent.nvim
   - `gitsigns.lua`: gitsigns config + signs setup (currently at lines 280-291)
   - `which-key.lua`: which-key keybinds (lines 307-358)
   - `telescope.lua`: telescope setup + keybinds (lines 367-468)
   - `lazydev.lua`: lazydev config (lines 472-483)
   - `lspconfig.lua`: LSP setup, mason, mason-lspconfig, fidget (lines 484-750)
   - `conform.lua`: conform.nvim formatter (lines 753-792)
   - `blink-cmp.lua`: blink.cmp completion (lines 794-891)
   - `tokyonight.lua`: colorscheme setup (lines 893-913)
   - `todo-comments.lua`: todo-comments plugin (line 916)
   - `mini.lua`: mini.nvim collections (lines 918-954)
   - `treesitter.lua`: treesitter setup (lines 955-979)

### Phase 3: Consolidate Existing Plugin Files

5. **Move kickstart optional plugins to `lua/plugins/`**
   - `lua/kickstart/plugins/neo-tree.lua` → `lua/plugins/neo-tree.lua`
   - `lua/kickstart/plugins/debug.lua` → Already handled as dap config
   - `lua/kickstart/plugins/gitsigns.lua` → Merge into `lua/plugins/gitsigns.lua`
   - `lua/kickstart/plugins/indent_line.lua` → `lua/plugins/indent-line.lua`
   - `lua/kickstart/plugins/autopairs.lua` → `lua/plugins/autopairs.lua`
   - `lua/kickstart/plugins/lint.lua` → `lua/plugins/lint.lua`

6. **Move custom plugins to `lua/plugins/`**
   - `lua/custom/plugins/trouble.lua` → `lua/plugins/trouble.lua`
   - `lua/custom/plugins/dap.lua` → `lua/plugins/dap-ui.lua`
   - `lua/custom/plugins/roslyn.lua` → `lua/plugins/roslyn.lua`
   - `lua/custom/plugins/lazygit.lua` → `lua/plugins/lazygit.lua`

7. **Create new plugin file**
   - `lua/plugins/tmux-navigator.lua` for vim-tmux-navigator (from custom/plugins/init.lua)

### Phase 4: Update Main Configuration Files

8. **Rewrite `init.lua`**
   - Remove all plugin configurations, keep only:
     - Leader key setup
     - Nerd font global
     - Require of lazy.nvim
     - Require of config modules (settings, keymaps, autocommands)
     - Lazy setup with require of plugins
   - Size should reduce from 1030 lines to ~80-100 lines

9. **Create `lua/plugins/init.lua`**
   - Import all plugin modules
   - Combine into single plugins table for lazy.nvim

### Phase 5: Cleanup

10. **Delete deprecated directories**
    - Remove `lua/kickstart/plugins/` (keep only health.lua if needed)
    - Remove `lua/custom/` directory structure

11. **Update documentation**
    - Add comments to each plugin file explaining its purpose
    - Update AGENTS.md if needed with new structure

## File Naming Conventions

- Use **lowercase with hyphens** for file names: `neo-tree.lua`, `blink-cmp.lua`, `indent-line.lua`
- Match plugin repository names where possible for clarity
- Descriptive names that indicate the plugin's purpose

## Benefits of This Restructuring

1. **Modularity**: Each plugin is isolated and independently manageable
2. **Maintainability**: Easy to find and modify specific plugin configurations
3. **Clarity**: Clear directory structure reflects plugin categorization
4. **Scalability**: Simple to add new plugins without cluttering init.lua
5. **Performance**: Lazy loading behavior unchanged, but code organization improved
6. **Readability**: init.lua becomes a clean entry point, not a 1000+ line monster

## Implementation Notes

- Use the lazy.nvim pattern: `{ import = 'plugins' }` to load all plugin specs
- Each plugin file should return a single spec or table of specs
- Preserve all existing keymaps and functionality
- Test with `:Lazy` and `:checkhealth` after each major phase
