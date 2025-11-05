return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local diffview = require 'diffview'
    diffview.setup {
      use_icons = true,
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = 'diff3_horizontal', -- 3-way side-by-side
          disable_diagnostics = true,
        },
      },
      file_panel = {
        win_config = { position = 'left', width = 35 },
      },
    }

    -- Optional keymaps
    vim.keymap.set('n', '<leader>do', '<cmd>DiffviewOpen<cr>', { desc = 'Open diffview' })
    vim.keymap.set('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' })
  end,
}
