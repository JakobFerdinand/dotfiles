-- dap-csharp.lua
-- C#/.NET debugging configuration with netcoredbg adapter
-- Handles .csproj discovery, target framework detection, and launch profile loading

return {
  'mfussenegger/nvim-dap',
  ft = 'cs',
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

    local profile_cache = {}

    local function load_launch_profiles(csproj_path)
      local project_dir = vim.fn.fnamemodify(csproj_path, ':h')
      local launch_path = project_dir .. '/Properties/launchSettings.json'
      if vim.fn.filereadable(launch_path) == 0 then
        return nil
      end

      local ok, lines = pcall(vim.fn.readfile, launch_path)
      if not ok or not lines then
        return nil
      end

      local content = table.concat(lines, '\n')
      local ok_json, data = pcall(vim.json.decode, content)
      if not ok_json or type(data) ~= 'table' then
        return nil
      end

      local profiles = data.profiles
      if type(profiles) ~= 'table' or next(profiles) == nil then
        return nil
      end

      return profiles
    end

    local function select_launch_profile(csproj_path, profiles)
      local project_dir = vim.fn.fnamemodify(csproj_path, ':h')
      local cache_key = vim.fn.fnamemodify(project_dir, ':p')
      local cached = profile_cache[cache_key]
      if cached and profiles[cached] then
        return cached
      end

      local names = vim.tbl_keys(profiles)
      table.sort(names)
      if #names == 0 then
        return nil
      end

      local project_name = vim.fn.fnamemodify(csproj_path, ':t:r')
      if profiles[project_name] then
        profile_cache[cache_key] = project_name
        return project_name
      end

      local project_candidates = {}
      for _, name in ipairs(names) do
        local profile = profiles[name]
        if type(profile) == 'table' and profile.commandName == 'Project' then
          project_candidates[#project_candidates + 1] = name
        end
      end

      table.sort(project_candidates)
      if #project_candidates == 1 then
        profile_cache[cache_key] = project_candidates[1]
        return project_candidates[1]
      end

      if #names == 1 then
        profile_cache[cache_key] = names[1]
        return names[1]
      end

      local options = { 'Select launch profile:' }
      for idx, name in ipairs(names) do
        options[#options + 1] = string.format('%d. %s', idx, name)
      end
      local choice = vim.fn.inputlist(options)
      if choice < 1 or choice > #names then
        return nil
      end
      profile_cache[cache_key] = names[choice]
      return names[choice]
    end

    local function build_launch_setup(csproj_path, profiles, profile_name)
      if not profile_name then
        return nil
      end

      local profile = profiles[profile_name]
      if type(profile) ~= 'table' then
        return nil
      end

      local project_dir = vim.fn.fnamemodify(csproj_path, ':h')
      local env = {}
      if type(profile.environmentVariables) == 'table' then
        for key, value in pairs(profile.environmentVariables) do
          env[key] = tostring(value)
        end
      end

      if type(profile.applicationUrl) == 'string' and profile.applicationUrl ~= '' and not env.ASPNETCORE_URLS then
        env.ASPNETCORE_URLS = profile.applicationUrl
      end

      if env.ASPNETCORE_ENVIRONMENT and not env.DOTNET_ENVIRONMENT then
        env.DOTNET_ENVIRONMENT = env.ASPNETCORE_ENVIRONMENT
      end

      if next(env) == nil then
        env = nil
      end

      local args
      if type(profile.commandLineArgs) == 'string' and profile.commandLineArgs ~= '' then
        args = vim.split(profile.commandLineArgs, '%s+', { trimempty = true })
        if #args == 0 then
          args = nil
        end
      elseif type(profile.commandLineArgs) == 'table' then
        args = profile.commandLineArgs
      end

      local cwd = project_dir
      if type(profile.workingDirectory) == 'string' and profile.workingDirectory ~= '' then
        local wd = profile.workingDirectory
        if not wd:match('^%a:[\\/]') and not wd:match('^/') then
          wd = project_dir .. '/' .. wd
        end
        local normalized = vim.fn.fnamemodify(wd, ':p')
        if vim.fn.isdirectory(normalized) == 1 then
          cwd = normalized
        end
      end

      return {
        env = env,
        args = args,
        cwd = cwd,
      }
    end

    -- Configure netcoredbg adapter for both normal and unit test debugging
    local netcoredbg_adapter = {
      type = 'executable',
      command = mason_path,
      args = { '--interpreter=vscode' },
    }

    dap.adapters.netcoredbg = netcoredbg_adapter
    dap.adapters.coreclr = netcoredbg_adapter

    local cs_config

    cs_config = {
      type = 'coreclr',
      name = 'launch - netcoredbg',
      request = 'launch',
      program = function()
        local buf_path = vim.api.nvim_buf_get_name(0)
        local default_path
        local csproj_path

        if buf_path and buf_path ~= '' then
          local buf_dir = vim.fn.fnamemodify(buf_path, ':h')
          csproj_path = find_nearest_csproj(buf_dir)
          if csproj_path then
            local candidates = build_candidate_paths(csproj_path)
            default_path = pick_default_path(candidates)

            local profiles = load_launch_profiles(csproj_path)
            local project_dir = vim.fn.fnamemodify(csproj_path, ':h')
            cs_config.cwd = project_dir
            if profiles then
              local profile_name = select_launch_profile(csproj_path, profiles)
              local setup = build_launch_setup(csproj_path, profiles, profile_name)
              if setup then
                cs_config.env = setup.env
                cs_config.args = setup.args
                cs_config.cwd = setup.cwd or project_dir
              else
                cs_config.env = nil
                cs_config.args = nil
              end
            else
              cs_config.env = nil
              cs_config.args = nil
            end
          end
        end

        if not csproj_path then
          cs_config.cwd = vim.fn.getcwd()
          cs_config.env = nil
          cs_config.args = nil
        end

        if not default_path or default_path == '' then
          default_path = vim.fn.getcwd() .. '/bin/Debug/net9.0/'
        end

        return vim.fn.input('Path to dll: ', default_path, 'file')
      end,
    }

    dap.configurations.cs = { cs_config }

    -- C# specific keymaps
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map('n', '<F5>', "<Cmd>lua require'dap'.continue()<CR>", opts)
    map('n', '<F6>', "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", opts)
    map('n', '<F9>', "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
    map('n', '<F10>', "<Cmd>lua require'dap'.step_over()<CR>", opts)
    map('n', '<F11>', "<Cmd>lua require'dap'.step_into()<CR>", opts)
    map('n', '<F8>', "<Cmd>lua require'dap'.step_out()<CR>", opts)
    map('n', '<leader>dr', "<Cmd>lua require'dap'.repl.open()<CR>", opts)
    map('n', '<leader>dl', "<Cmd>lua require'dap'.run_last()<CR>", opts)
    map('n', '<leader>dt', "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", { noremap = true, silent = true, desc = 'debug nearest test' })
  end,
}
