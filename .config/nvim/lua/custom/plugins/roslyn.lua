return {
  'seblyng/roslyn.nvim',
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    -- your configuration comes here; leave empty for default settings
  },
  config = function(_, opts)
    require('roslyn').setup(opts)

    local map = vim.keymap.set

    -- 🔍 Find the nearest file upwards matching any of the supplied extensions
    local function find_file_upwards_with_extension(exts)
      if type(exts) == 'string' then
        exts = { exts }
      end

      if not exts or vim.tbl_isempty(exts) then
        return nil
      end

      local normalized = {}
      for _, ext in ipairs(exts) do
        normalized[#normalized + 1] = (ext:gsub('^%.', '')):lower()
      end

      local bufname = vim.api.nvim_buf_get_name(0)
      local start_dir = bufname ~= '' and vim.fn.fnamemodify(bufname, ':p:h') or vim.fn.getcwd()

      local results = vim.fs.find(function(name, _)
        name = name:lower()
        for _, ext in ipairs(normalized) do
          if name:sub(-(#ext + 1)) == '.' .. ext then
            return true
          end
        end
        return false
      end, { upward = true, path = start_dir })
      return results[1]
    end

    -- 🧠 Helper: extract file name (without extension)
    local function get_name_from_path(path)
      return vim.fn.fnamemodify(path, ':t:r')
    end

    -- ⚙️ Build current project (.csproj)
    local function build_project()
      local csproj = find_file_upwards_with_extension 'csproj'
      if not csproj then
        vim.notify('No .csproj file found in current or parent directories.', vim.log.levels.WARN)
        return
      end
      local name = get_name_from_path(csproj)
      vim.system({ 'dotnet', 'build', csproj }, { text = true }, function(obj)
        vim.schedule(function()
          if obj.code == 0 then
            vim.notify(("✅ Project '%s' built successfully"):format(name), vim.log.levels.INFO)
          else
            vim.notify(("❌ Project '%s' build failed:\n%s"):format(name, obj.stderr), vim.log.levels.ERROR)
          end
        end)
      end)
    end

    -- ⚙️ Build entire solution (.sln or .slnx)
    local function build_solution()
      local sln = find_file_upwards_with_extension { 'sln', 'slnx' }
      if not sln then
        vim.notify('No .sln or .slnx file found in current or parent directories.', vim.log.levels.WARN)
        return
      end
      local name = get_name_from_path(sln)
      vim.system({ 'dotnet', 'build', sln }, { text = true }, function(obj)
        vim.schedule(function()
          if obj.code == 0 then
            vim.notify(("✅ Solution '%s' built successfully"):format(name), vim.log.levels.INFO)
          else
            vim.notify(("❌ Solution '%s' build failed:\n%s"):format(name, obj.stderr), vim.log.levels.ERROR)
          end
        end)
      end)
    end

    -- ⌨️ Keymaps (with helpful descriptions)
    map('n', '<leader>bc', build_project, {
      noremap = true,
      silent = true,
      desc = 'Build current C# project (.csproj)',
    })

    map('n', '<leader>bs', build_solution, {
      noremap = true,
      silent = true,
      desc = 'Build entire C# solution (.sln or .slnx)',
    })
  end,
}
