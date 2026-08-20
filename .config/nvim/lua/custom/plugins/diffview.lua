return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local diffview = require 'diffview'
    local actions = require 'diffview.actions'
    local JobStatus = require('diffview.vcs.utils').JobStatus

    local refresh_watchers = {}
    local refresh_pending = {}

    local function refresh_file_history(view)
      view.panel:update_entries(function(_, status)
        if status >= JobStatus.ERROR then
          return
        end
        if not view:cur_file() then
          view:next_item()
        end
      end)
    end

    diffview.setup {
      use_icons = true,
      enhanced_diff_hl = true,
      keymaps = {
        file_history_panel = {
          { 'n', 'R', actions.refresh_files, { desc = 'Refresh file history' } },
        },
        view = {
          { 'n', 'R', actions.refresh_files, { desc = 'Refresh file history' } },
        },
      },
      hooks = {
        view_opened = function(view)
          if view.class:name() ~= 'FileHistoryView' then
            return
          end
          local head_log = view.adapter.ctx.dir .. '/logs/HEAD'
          if not vim.uv.fs_stat(head_log) then
            return
          end
          local watcher = vim.uv.new_fs_poll()
          watcher:start(
            head_log,
            1000,
            vim.schedule_wrap(function(err)
              if err then
                return
              end
              if view:is_cur_tabpage() then
                refresh_file_history(view)
              else
                refresh_pending[view] = true
              end
            end)
          )
          refresh_watchers[view] = watcher
        end,
        view_enter = function(view)
          if refresh_pending[view] then
            refresh_pending[view] = nil
            refresh_file_history(view)
          end
        end,
        view_closed = function(view)
          local watcher = refresh_watchers[view]
          if watcher then
            watcher:stop()
          end
          refresh_watchers[view] = nil
          refresh_pending[view] = nil
        end,
      },
      view = {
        merge_tool = {
          layout = 'diff4_mixed',
          --[[
                ┌────┬────┬────┐
                │ A  │ D  │ C  │
                │    │    │    │
                ├────┴────┴────┤
                │      B       │
                │              │
                └──────────────┘
		]]
          --
          disable_diagnostics = true,
        },
      },
      file_panel = {
        win_config = { position = 'left', width = 35 },
      },
    }

    -- Optional keymaps
    vim.keymap.set('n', '<leader>do', '<cmd>DiffviewOpen<cr>', { desc = 'Open diffview' })
    vim.keymap.set('n', '<leader>dh', '<cmd>DiffviewFileHistory<cr>', { desc = 'Open diffview history' })
    vim.keymap.set('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' })
  end,
}
