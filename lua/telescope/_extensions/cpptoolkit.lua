local I = require 'cpp-toolkit.include'

local telescope = require('telescope')
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')
local conf = require('telescope.config').values
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local utils = require "telescope.utils"

local function insert_header_files(opts)
  local headers = I.list_header_files()
  pickers.new(opts, {
    prompt_title = 'Header Files',
    finder = finders.new_table {
      results = headers,
      entry_maker = function(entry)
        return {
          value = entry.value,
          display = function(entry)
            local hl_group
            local display = utils.transform_path(opts, entry.value)

            display, hl_group = utils.transform_devicons(entry.value, display,
                                                         false)

            if hl_group then
              return display, { { { 1, 3 }, hl_group } }
            else
              return display
            end
          end,
          ordinal = entry.value,
          path = entry.path,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    previewer = conf.file_previewer(opts),
    attach_mappings = function(bufnr, map)
      map('i', '<CR>', function()
        local entry = action_state.get_selected_entry()
        actions.close(bufnr)
        local line = '#include "' .. entry.value .. '"'
        vim.api.nvim_put({ line }, '', true, true)
      end)

      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = { insert_header = insert_header_files },
}
