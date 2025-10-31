return {
  -- Debug Framework
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    local dap = require 'dap'

    local mason_path = vim.fn.stdpath 'data' .. '/mason/packages/netcoredbg/netcoredbg'
    local function trim(s)
      if not s then
        return nil
      end
      return (s:gsub('^%s+', ''):gsub('%s+$', ''))
    end

    local function find_nearest_csproj(start_dir)
      local dir = start_dir
      while dir and dir ~= '' do
        local matches = vim.fn.globpath(dir, '*.csproj', 0, 1)
        if matches and #matches > 0 then
          table.sort(matches)
          return matches[1]
        end
        local parent = vim.fn.fnamemodify(dir, ':h')
        if not parent or parent == dir then
          break
        end
        dir = parent
      end
      return nil
    end

    local function target_frameworks(csproj_path)
      local frameworks = {}
      local ok, lines = pcall(vim.fn.readfile, csproj_path)
      if not ok or not lines then
        return frameworks
      end
      for _, line in ipairs(lines) do
        local single = line:match('<TargetFramework>%s*([^<%s]+)%s*</TargetFramework>')
        if single then
          frameworks[#frameworks + 1] = trim(single)
          break
        end
        local multi = line:match('<TargetFrameworks>%s*([^<]+)%s*</TargetFrameworks>')
        if multi then
          for tfm in multi:gmatch('[^;]+') do
            frameworks[#frameworks + 1] = trim(tfm)
          end
          break
        end
      end
      return frameworks
    end

    local function build_candidate_paths(csproj_path)
      local candidates = {}
      local project_dir = vim.fn.fnamemodify(csproj_path, ':h')
      local project_name = vim.fn.fnamemodify(csproj_path, ':t:r')
      local frameworks = target_frameworks(csproj_path)

      if #frameworks == 0 then
        frameworks = { 'net9.0', 'net8.0', 'net7.0', 'net6.0', 'net5.0', 'netcoreapp3.1' }
      end

      for _, tfm in ipairs(frameworks) do
        candidates[#candidates + 1] = string.format('%s/bin/Debug/%s/%s.dll', project_dir, tfm, project_name)
      end

      local glob_pattern = project_dir .. '/bin/**/' .. project_name .. '.dll'
      local matches = vim.fn.glob(glob_pattern, 0, 1)
      if type(matches) == 'table' then
        for _, path in ipairs(matches) do
          if not vim.tbl_contains(candidates, path) then
            candidates[#candidates + 1] = path
          end
        end
      end

      return candidates
    end

    local function pick_default_path(candidates)
      if #candidates == 0 then
        return nil
      end

      for _, path in ipairs(candidates) do
        if path:match('[\\/][Dd]ebug[\\/]') and vim.fn.filereadable(path) == 1 then
          return path
        end
      end

      for _, path in ipairs(candidates) do
        if vim.fn.filereadable(path) == 1 then
          return path
        end
      end

      return candidates[1]
    end

    local netcoredbg_adapter = {
      type = 'executable',
      command = mason_path,
      args = { '--interpreter=vscode' },
    }

    dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
    dap.adapters.coreclr = netcoredbg_adapter -- needed for unit test debugging

    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'launch - netcoredbg',
        request = 'launch',
        program = function()
          local buf_path = vim.api.nvim_buf_get_name(0)
          local default_path

          if buf_path and buf_path ~= '' then
            local buf_dir = vim.fn.fnamemodify(buf_path, ':h')
            local csproj_path = find_nearest_csproj(buf_dir)
            if csproj_path then
              local candidates = build_candidate_paths(csproj_path)
              default_path = pick_default_path(candidates)
            end
          end

          if not default_path or default_path == '' then
            default_path = vim.fn.getcwd() .. '/bin/Debug/net9.0/'
          end

          return vim.fn.input('Path to dll: ', default_path, 'file')
        end,

        -- justMyCode = false,
        -- stopAtEntry = false,
        -- -- program = function()
        -- --   -- todo: request input from ui
        -- --   return "/path/to/your.dll"
        -- -- end,
        -- env = {
        --   ASPNETCORE_ENVIRONMENT = function()
        --     -- todo: request input from ui
        --     return "Development"
        --   end,
        --   ASPNETCORE_URLS = function()
        --     -- todo: request input from ui
        --     return "http://localhost:5050"
        --   end,
        -- },
        -- cwd = function()
        --   -- todo: request input from ui
        --   return vim.fn.getcwd()
        -- end,
      },
    }

    local map = vim.keymap.set

    local opts = { noremap = true, silent = true }

    map('n', '<F5>', "<Cmd>lua require'dap'.continue()<CR>", opts)
    map('n', '<F6>', "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", opts)
    map('n', '<F9>', "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
    map('n', '<F10>', "<Cmd>lua require'dap'.step_over()<CR>", opts)
    map('n', '<F11>', "<Cmd>lua require'dap'.step_into()<CR>", opts)
    map('n', '<F8>', "<Cmd>lua require'dap'.step_out()<CR>", opts)
    -- map("n", "<F12>", "<Cmd>lua require'dap'.step_out()<CR>", opts)
    map('n', '<leader>dr', "<Cmd>lua require'dap'.repl.open()<CR>", opts)
    map('n', '<leader>dl', "<Cmd>lua require'dap'.run_last()<CR>", opts)
    map('n', '<leader>dt', "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", { noremap = true, silent = true, desc = 'debug nearest test' })

    local dapui = require 'dapui'
    --- open ui immediately when debugging starts
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    -- default configuration
    dapui.setup()
  end,
  event = 'VeryLazy',
}
