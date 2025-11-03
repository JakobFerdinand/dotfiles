-- kdheepak/lazygit.nvim: Integrates LazyGit TUI for git operations.
-- Exposes :LazyGit and related commands; keymap under <leader>lg.
return {
  'kdheepak/lazygit.nvim',
  lazy = true,
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
  },
}
