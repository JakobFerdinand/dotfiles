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

    --- Shared state for the build output window/job
    local build_output = {
      buf = nil,
      win = nil,
      job = nil,
    }

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

    -- 🧵 Join a command list for display purposes
    local function join_command(cmd)
      local parts = {}
      for _, part in ipairs(cmd) do
        if part:find('%s') then
          parts[#parts + 1] = ('"%s"'):format(part)
        else
          parts[#parts + 1] = part
        end
      end
      return table.concat(parts, ' ')
    end

    -- 🪟 Ensure the vertical output window exists (re-using if possible)
    local function ensure_output_window(title, command_display)
      if build_output.buf and not vim.api.nvim_buf_is_valid(build_output.buf) then
        build_output.buf = nil
      end
      if build_output.win and not vim.api.nvim_win_is_valid(build_output.win) then
        build_output.win = nil
      end

      if not build_output.buf then
        build_output.buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(build_output.buf, 'Roslyn Build Output')
        vim.api.nvim_buf_set_option(build_output.buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(build_output.buf, 'bufhidden', 'hide')
        vim.api.nvim_buf_set_option(build_output.buf, 'swapfile', false)
        vim.api.nvim_buf_set_option(build_output.buf, 'filetype', 'roslynbuild')
      end

      if not build_output.win then
        local current_win = vim.api.nvim_get_current_win()
        vim.cmd 'botright split'
        build_output.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(build_output.win, build_output.buf)
        vim.api.nvim_set_current_win(current_win)
      else
        vim.api.nvim_win_set_buf(build_output.win, build_output.buf)
      end

      local header = {
        ('# %s'):format(title),
        ('$ ' .. command_display),
        '',
      }
      vim.api.nvim_buf_set_lines(build_output.buf, 0, -1, false, header)

      return build_output.buf
    end

    -- 📝 Append new lines to the output buffer (scheduled on the main loop)
    local function append_lines(buf, lines)
      if not lines or #lines == 0 then
        return
      end
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
        local win = vim.fn.bufwinid(buf)
        if win ~= -1 then
          vim.api.nvim_win_call(win, function()
            vim.cmd 'normal! G'
          end)
        end
      end)
    end

    -- 🔊 Produce handlers that stream stdout/stderr into the output buffer
    local function make_stream_handler(buf, prefix)
      prefix = prefix or ''
      local pending = ''
      local function render(line)
        local sanitized = line:gsub('\r$', '')
        if sanitized == '' then
          return prefix == '' and '' or prefix
        end
        return prefix .. sanitized
      end
      return function(_, data)
        if not data then
          if pending ~= '' then
            append_lines(buf, { render(pending) })
            pending = ''
          end
          return
        end
        if data == '' then
          return
        end
        local text = pending .. data
        local lines = vim.split(text, '\n', { plain = true })
        pending = table.remove(lines) or ''
        if #lines > 0 then
          for i, line in ipairs(lines) do
            lines[i] = render(line)
          end
          append_lines(buf, lines)
        end
      end
    end

    -- 🚀 Kick off the build and stream output into the dedicated window
    local function run_build(cmd, label)
      if build_output.job then
        local ok, closing = pcall(function()
          return build_output.job:is_closing()
        end)
        if (ok and not closing) or not ok then
          pcall(function()
            build_output.job:kill 'sigterm'
          end)
        end
      end
      build_output.job = nil

      local command_display = join_command(cmd)
      local buf = ensure_output_window(('Building %s'):format(label), command_display)

      build_output.job = vim.system(cmd, {
        stdout = make_stream_handler(buf, ''),
        stderr = make_stream_handler(buf, '[stderr] '),
      }, function(obj)
        build_output.job = nil
        local summary = obj.code == 0 and '✅ Build succeeded' or '❌ Build failed'
        append_lines(buf, { '', ('%s (exit code %d)'):format(summary, obj.code) })
        vim.schedule(function()
          local level = obj.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
          vim.notify(("%s for %s"):format(summary, label), level)
        end)
      end)
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
      run_build({ 'dotnet', 'build', csproj }, ("project '%s'"):format(name))
    end

    -- ⚙️ Build entire solution (.sln or .slnx)
    local function build_solution()
      local sln = find_file_upwards_with_extension { 'sln', 'slnx' }
      if not sln then
        vim.notify('No .sln or .slnx file found in current or parent directories.', vim.log.levels.WARN)
        return
      end
      local name = get_name_from_path(sln)
      run_build({ 'dotnet', 'build', sln }, ("solution '%s'"):format(name))
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
