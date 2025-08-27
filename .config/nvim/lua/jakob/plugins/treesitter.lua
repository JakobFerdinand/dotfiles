return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      local treesitter = require("nvim-treesitter.configs")

      treesitter.setup({
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
        ensure_installed = {
          "bash",
          "bicep",
          "c",
          "css",
          "c_sharp",
          "dockerfile",
          "editorconfig",
          "elm",
          "gitignore",
          "graphql",
          "help",
          "html",
          "http",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "mermaid",
          "powershell",
          "prisma",
          "python",
          "regex",
          "rust",
          "query",
          "sql",
          "svelte",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "xml",
          "yaml",
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end
  },
  "nvim-treesitter/playground"
}
