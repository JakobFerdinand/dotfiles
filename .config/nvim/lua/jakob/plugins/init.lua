return {
  "nvim-lua/plenary.nvim",
  {
    "christoomey/vim-tmux-navigator",
    config = function()
      local keymap = vim.keymap
      keymap.set("n", "<leader>h", ":<C-U>TmuxNavigateLeft<cr>", { desc = "Navigate Left" })
      keymap.set("n", "<leader>j", ":<C-U>TmuxNavigateDown<cr>", { desc = "Navigate Down" })
      keymap.set("n", "<leader>k", ":<C-U>TmuxNavigateUp<cr>", { desc = "Navigate Up" })
      keymap.set("n", "<leader>l", ":<C-U>TmuxNavigateRight<cr>", { desc = "Navigate Right" })
      keymap.set("n", "<leader>p", ":<C-U>TmuxNavigatePrevious<cr>", { desc = "Navigate Previous" })
    end
  },
  "github/copilot.vim"
}
