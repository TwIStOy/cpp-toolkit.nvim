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
local function textedit_from_node(node, fmt, ctx)
  local text = util_ts.get_node_text(node)
  local new_text
  if type(fmt) == 'string' then
    new_text = string.format(fmt, text)
  else
    new_text = fmt(text, ctx)
  end

  return { range = util_ts.get_lsp_range(node), newText = new_text }
end

---Get the elements of a comma expression.
---@param node TSNode
local function comma_expression_elements(node)
  local left = node:field("left")[1]
  local right = node:field("right")[1]
  local res = { util_ts.get_node_text(left) }
  if right:type() == 'comma_expression' then
    return vim.list_extend(res, comma_expression_elements(right))
  else
    table.insert(res, util_ts.get_node_text(right))
    return res
  end
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

function M.shortcut_stdcout_values()
  local node = ts_utils.get_node_at_cursor()
  node = util_ts.find_topmost_parent(node, 'comma_expression')
  if node == nil then
    --- generate stdcout for object_expr
    local node = object_expr_at_cursor()
    if node == nil then
      return
    end
    vim.lsp.util.apply_text_edits({
      textedit_from_node(node, function(txt)
        return string.format([[std::cout << "%s = " << %s << std::endl]], txt,
                             txt)
      end),
    }, 0, 'utf-16')
    return
  else
    --- generate stdcout for a list of values
    local elements = comma_expression_elements(node)
    local fmt_elements = {}
    for i, e in ipairs(elements) do
      if i == 1 then
        table.insert(fmt_elements, string.format('"%s = " << %s', e, e))
      else
        table.insert(fmt_elements, string.format('", %s = " << %s', e, e))
      end
    end

    local text_edit = {
      range = util_ts.get_lsp_range(node),
      newText = string.format("std::cout << %s << std::endl",
                              table.concat(fmt_elements, " << ")),
    }

    vim.lsp.util.apply_text_edits({ text_edit }, 0, 'utf-16')
  end
end

M.shortcuts = {
  move_value = M.shortcut_move_value,
  forward_value = M.shortcut_forward_value,
  stdcout_values = M.shortcut_stdcout_values,
}

return M
