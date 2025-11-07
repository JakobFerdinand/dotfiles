local function with_neotest(callback)
  return function(...)
    local ok, neotest = pcall(require, 'neotest')
    if not ok then
      vim.notify('neotest is not available', vim.log.levels.ERROR)
      return
    end
    return callback(neotest, ...)
  end
end

return {
  'nvim-neotest/neotest',
  dependencies = {
    'Issafalcon/neotest-dotnet',
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
  },
  keys = {
    {
      '<leader>tt',
      with_neotest(function(neotest)
        neotest.run.run()
      end),
      desc = 'Run nearest test',
    },
    {
      '<leader>tT',
      with_neotest(function(neotest)
        neotest.run.run(vim.fn.expand '%')
      end),
      desc = 'Run current file tests',
    },
    {
      '<leader>ta',
      with_neotest(function(neotest)
        neotest.run.run { suite = true }
      end),
      desc = 'Run entire test suite',
    },
    {
      '<leader>ts',
      with_neotest(function(neotest)
        neotest.summary.toggle()
      end),
      desc = 'Toggle test summary',
    },
    {
      '<leader>to',
      with_neotest(function(neotest)
        neotest.output.open { enter = true }
      end),
      desc = 'Open last test output',
    },
    {
      '<leader>tS',
      with_neotest(function(neotest)
        neotest.run.stop()
      end),
      desc = 'Stop running tests',
    },
    {
      '<F6>',
      with_neotest(function(neotest)
        neotest.run.run { strategy = 'dap' }
      end),
      desc = 'Debug nearest test',
    },
    {
      '<leader>dt',
      with_neotest(function(neotest)
        neotest.run.run { strategy = 'dap' }
      end),
      desc = 'Debug nearest test',
    },
  },
  config = function()
    local neotest = require 'neotest'
    neotest.setup {
      adapters = {
        require 'neotest-dotnet' {},
      },
    }
  end,
}
