return {
  'github/copilot.vim',
  event = 'VeryLazy',
  config = function()
    vim.g.copilot_filetypes = {
      ['*'] = true, -- Enable for all filetypes by default
      mdx = true, -- Explicitly enable for MDX
    }
  end,
}
