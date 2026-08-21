-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'christoomey/vim-tmux-navigator',
  -- vim-herdr-navigation (sourced below) is linux/macos-only; on Windows its
  -- <C-h/j/k/l> bindings would swallow those keys. Native Windows has no tmux
  -- either, so skip the whole spec there (WSL still reports Linux).
  enabled = function()
    return vim.uv.os_uname().sysname ~= 'Windows_NT'
  end,
  lazy = false,
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  config = function()
    dofile(vim.fn.expand '~/.config/herdr/plugins/vim-herdr-navigation/editor/nvim.lua')
  end,
}
