local util_ts = require 'cpp-toolkit.util.ts'
local ts_utils = require 'nvim-treesitter.ts_utils'

local M = {}

local object_expr_types = { 'call_expression', 'identifier' }

---@return TSNode|nil
local function object_expr_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  local parent = util_ts.find_first_parent(node, object_expr_types)
  return parent
end

---@param node TSNode
---@param fmt string | function
local function textedit_from_node(node, fmt)
  local text = util_ts.get_node_text(node)
  local new_text
  if type(fmt) == 'string' then
    new_text = string.format(fmt, text)
  else
    new_text = fmt(text)
  end

  local start_row, start_col, end_row, end_col = node:range()
  local range = {
    start = { line = start_row, character = start_col },
    ['end'] = { line = end_row, character = end_col },
  }
  return { range = range, newText = new_text }
end

function M.shortcut_move_value()
  local node = object_expr_at_cursor()
  if node == nil then
    return
  end
  vim.lsp.util.apply_text_edits({ textedit_from_node(node, 'std::move(%s)') },
                                0, 'utf-16')
end

function M.shortcut_forward_value()
  local node = object_expr_at_cursor()
  if node == nil then
    return
  end
  vim.lsp.util.apply_text_edits({
    textedit_from_node(node, function(txt)
      return string.format("std::forward<%s>(%s)", txt, txt)
    end),
  }, 0, 'utf-16')
end

return M
