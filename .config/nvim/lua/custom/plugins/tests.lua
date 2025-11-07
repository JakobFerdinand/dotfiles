return {
  'nvim-neotest/neotest',
  dependencies = {
    'Issafalcon/neotest-dotnet',
  },
  config = function()
    local neotest = require 'neotest'
    neotest.setup {
      adapters = {
        require 'neotest-dotnet',
      },
    }
  end,
}
