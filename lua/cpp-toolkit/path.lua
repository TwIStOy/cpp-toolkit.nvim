local M = {}

local Path = require 'plenary.path'
local UA = require 'cpp-toolkit.util.array'

local header_ext = {
  'h', 'hh', 'hpp', 'hxx',
}

local source_ext = {
  'c', 'cc', 'cpp', 'cxx',
}

local ext_translate = {
}

local include_folders = { 'include', 'includes', 'inc', 'incs' }
local same_level_source_folders = { 'src', 'srcs', 'source', 'sources' }

function M.test()
  local current_file = Path.new(vim.fn.expand('%:p'))
  local path_parts = UA.filter(current_file:_split(), function(s)
    return #s > 0
  end)

  vim.print(path_parts)

  -- try header/source in the same folder
end

return M
