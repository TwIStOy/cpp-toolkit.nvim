local M = {}

local R = require 'cpp-toolkit.rooter'
local ts_utils = require 'nvim-treesitter.ts_utils'

local DEFAULT_DEBUGPRINT_TEMPLATE =
    [[std::cout << "DEBUGPRINT:" << __FILE__ << ":" << __LINE__ << ":" << __FUNCTION__ << ":" << __COUNTER__ << ": " << $VAR << std::endl;]]

local function get_debugprint_template()
  if vim.b.cpp_toolkit_debugprint_template == nil then
    -- resolve template
    local root = R.get_resolved_root()
    if root == nil then
      vim.notify('[cpp-toolkit.nvim] No root found for current file.',
                 vim.log.levels.WARN)
      return
    end
  end
  return vim.b.cpp_toolkit_debugprint_template
end

function M.debugprint()
  local template = get_debugprint_template()
  if template == nil then
    template = DEFAULT_DEBUGPRINT_TEMPLATE
  end

  local node = ts_utils.get_node_at_cursor()
  if node:type() ~= 'identifier' then
    return
  end

  local text = vim.treesitter.get_node_text(node, 0)
  return string.gsub(template, "$VAR", text)
end

return M
