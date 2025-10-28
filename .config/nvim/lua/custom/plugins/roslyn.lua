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
      main_win = nil,
    }
    local highlight_ns = vim.api.nvim_create_namespace 'roslyn_build_output'

    local function configure_output_buffer(buf)
      local options = {
        buftype = 'nofile',
        bufhidden = 'hide',
        swapfile = false,
        filetype = 'roslynbuild',
      }
      for option, value in pairs(options) do
        vim.api.nvim_buf_set_option(buf, option, value)
      end
    end

    local function is_float_win(win)
      return vim.api.nvim_win_get_config(win).relative ~= ''
    end

    local function is_neo_tree_win(win)
      if not win or not vim.api.nvim_win_is_valid(win) then
        return false
      end
      local ok_buf, buf = pcall(vim.api.nvim_win_get_buf, win)
      if not ok_buf or not vim.api.nvim_buf_is_valid(buf) then
        return false
      end
      local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
      return type(ft) == 'string' and ft:match('^neo%-tree')
    end

    local function pick_split_target_window(original_win)
      if original_win and vim.api.nvim_win_is_valid(original_win) and not is_float_win(original_win) and not is_neo_tree_win(original_win) then
        return original_win
      end

      local previous = vim.fn.win_getid(vim.fn.winnr '#')
      if previous ~= 0 and vim.api.nvim_win_is_valid(previous) and not is_float_win(previous) and not is_neo_tree_win(previous) then
        return previous
      end

      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not is_float_win(win) and not is_neo_tree_win(win) then
          return win
        end
      end

      return original_win
    end

    local function is_build_output_win(win)
      return build_output.win ~= nil and win == build_output.win
    end

    local function pick_edit_window()
      local win = build_output.main_win
      if win and vim.api.nvim_win_is_valid(win) and not is_float_win(win) and not is_neo_tree_win(win) and not is_build_output_win(win) then
        return win
      end

      for _, candidate in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not is_float_win(candidate) and not is_neo_tree_win(candidate) and not is_build_output_win(candidate) then
          build_output.main_win = candidate
          return candidate
        end
      end

      return nil
    end

    local function stop_active_job()
      if not build_output.job then
        return
      end
      local job = build_output.job
      build_output.job = nil
      local ok, closing = pcall(function()
        return job:is_closing()
      end)
      if not ok then
        closing = false
      end
      if not closing then
        pcall(function()
          job:kill 'sigterm'
        end)
      end
    end

    local function close_output_window()
      stop_active_job()
      if build_output.win and vim.api.nvim_win_is_valid(build_output.win) then
        pcall(vim.api.nvim_win_close, build_output.win, true)
      end
      build_output.win = nil
    end

    local function jump_to_location(location)
      if not location or not location.file then
        return
      end

      local target_win = pick_edit_window()
      if not target_win or not vim.api.nvim_win_is_valid(target_win) then
        vim.cmd 'botright vsplit'
        target_win = vim.api.nvim_get_current_win()
        if not target_win or not vim.api.nvim_win_is_valid(target_win) then
          vim.notify('Unable to create window for build location.', vim.log.levels.ERROR)
          return
        end
      end

      build_output.main_win = target_win

      local escaped = vim.fn.fnameescape(location.file)
      local current_win = vim.api.nvim_get_current_win()
      if current_win ~= target_win then
        vim.api.nvim_set_current_win(target_win)
      end

      vim.cmd('edit ' .. escaped)

      local row = math.max(location.row or 1, 1)
      local col = math.max((location.col or 1) - 1, 0)
      vim.api.nvim_win_set_cursor(target_win, { row, col })
    end

    local function extract_location_from_line(line)
      if not line or line == '' then
        return nil
      end

      -- Match absolute or relative path:line,column pattern produced by dotnet.
      -- Example: path/to/file.cs(12,34): error CS0001: message
      local file, row, col = line:match '^%s*(.-)%((%d+),(%d+)%)'
      if not file then
        file, row = line:match '^%s*(.-)%((%d+)%)'
        if file then
          col = '1'
        end
      end
      if not file then
        file, row, col = line:match '^%s*(.+):(%d+):(%d+)'
      end
      if not file then
        file, row = line:match '^%s*(.+):(%d+)'
        if file then
          col = '1'
        end
      end

      if not file then
        return nil
      end

      local expanded = vim.fn.fnamemodify(file, ':p')
      row = tonumber(row) or 1
      col = tonumber(col) or 1

      return {
        file = expanded,
        row = row,
        col = col,
      }
    end

    -- Find the nearest file upwards matching any of the supplied extensions
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

    -- Join a command list for display purposes
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

    -- Ensure the horizontal output window exists (re-using if possible)
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
        configure_output_buffer(build_output.buf)
        vim.keymap.set('n', 'q', close_output_window, {
          buffer = build_output.buf,
          silent = true,
          desc = 'Close build output pane',
          nowait = true,
        })
        vim.keymap.set('n', '<CR>', function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local line = vim.api.nvim_buf_get_lines(build_output.buf, cursor[1] - 1, cursor[1], false)[1]
          local location = extract_location_from_line(line or '')
          if not location then
            vim.notify('Could not parse location from build output line.', vim.log.levels.WARN)
            return
          end
          if not vim.loop.fs_stat(location.file) then
            vim.notify(('File not found: %s'):format(location.file), vim.log.levels.ERROR)
            return
          end
          jump_to_location(location)
        end, {
          buffer = build_output.buf,
          silent = true,
          desc = 'Open location from build output',
        })
      end

      if not build_output.win then
        local original_win = vim.api.nvim_get_current_win()
        local target_win = pick_split_target_window(original_win)

        if target_win and vim.api.nvim_win_is_valid(target_win) then
          vim.api.nvim_set_current_win(target_win)
        else
          target_win = original_win
        end

        if not target_win or not vim.api.nvim_win_is_valid(target_win) or is_neo_tree_win(target_win) then
          -- Create a fresh window to host the build output without reusing Neo-tree.
          vim.cmd 'botright vsplit'
          target_win = vim.api.nvim_get_current_win()
        end

        if target_win and vim.api.nvim_win_is_valid(target_win) then
          build_output.main_win = target_win
        end

        vim.cmd 'botright split'
        build_output.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(build_output.win, build_output.buf)

        if original_win and vim.api.nvim_win_is_valid(original_win) then
          vim.api.nvim_set_current_win(original_win)
        end
      else
        vim.api.nvim_win_set_buf(build_output.win, build_output.buf)
      end

      local header = {
        ('# %s'):format(title),
        ('$ ' .. command_display),
        '',
      }
      vim.api.nvim_buf_clear_namespace(build_output.buf, highlight_ns, 0, -1)
      vim.api.nvim_buf_set_lines(build_output.buf, 0, -1, false, header)

      return build_output.buf
    end

    local function classify_highlight(line)
      local lowered = line:lower()
      if lowered:find('error', 1, true) or lowered:find('failed', 1, true) then
        return 'ErrorMsg'
      end
      if lowered:find('warning', 1, true) then
        return 'WarningMsg'
      end
      return nil
    end

    -- Append new lines to the output buffer (scheduled on the main loop)
    local function append_lines(buf, lines)
      if not lines or #lines == 0 then
        return
      end
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        local start_line = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
        for idx, line in ipairs(lines) do
          local hl = classify_highlight(line)
          if hl then
            vim.api.nvim_buf_add_highlight(buf, highlight_ns, hl, start_line + idx - 1, 0, -1)
          end
        end
        local win = vim.fn.bufwinid(buf)
        if win ~= -1 then
          vim.api.nvim_win_call(win, function()
            vim.cmd 'normal! G'
          end)
        end
      end)
    end

    -- Produce handlers that stream stdout/stderr into the output buffer
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

    -- Kick off the build and stream output into the dedicated window
    local function run_build(cmd, label)
      stop_active_job()

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

    -- Helper: extract file name (without extension)
    local function get_name_from_path(path)
      return vim.fn.fnamemodify(path, ':t:r')
    end

    local function build_with_extensions(exts, not_found_message, label_template)
      local path = find_file_upwards_with_extension(exts)
      if not path then
        vim.notify(not_found_message, vim.log.levels.WARN)
        return
      end
      local name = get_name_from_path(path)
      run_build({ 'dotnet', 'build', path }, label_template:format(name))
    end

    -- Build current project (.csproj)
    local function build_project()
      build_with_extensions('csproj', 'No .csproj file found in current or parent directories.', "project '%s'")
    end

    -- Build entire solution (.sln or .slnx)
    local function build_solution()
      build_with_extensions({ 'sln', 'slnx' }, 'No .sln or .slnx file found in current or parent directories.', "solution '%s'")
    end

    map('n', '<leader>gd', vim.lsp.buf.definition, {
      noremap = true,
      silent = true,
      desc = 'Go to definition (C#)',
    })

    map('n', '<leader>gi', vim.lsp.buf.implementation, {
      noremap = true,
      silent = true,
      desc = 'Go to implementation (C#)',
    })

    map('n', '<leader>ca', vim.lsp.buf.code_action, {
      noremap = true,
      silent = true,
      desc = 'Code actions (C#)',
    })

    map('n', '<leader>fr', vim.lsp.buf.references, {
      noremap = true,
      silent = true,
      desc = 'Find references (C#)',
    })

    map('n', '<leader>rr', vim.lsp.buf.rename, {
      noremap = true,
      silent = true,
      desc = 'Rename symbol (C#)',
    })

    -- Keymaps (with helpful descriptions)
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
