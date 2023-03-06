local M = {}

local parsers = require 'nvim-treesitter.parsers'
local TSRange = require'nvim-treesitter.tsrange'.TSRange
local ts_utils = require 'nvim-treesitter.ts_utils'
local A = vim.api

local function cmp_position(row0, col0, row1, col1)
  if row0 ~= row1 then
    return row0 - row1
  else
    return col0 - col1
  end
end

local function get_nodes_in_range_impl(root, start_row, start_col, end_row,
                                       end_col)
  if root == nil then
    return {}
  end

  local root_start_row, root_start_col, root_end_row, root_end_col =
      root:range()

  if cmp_position(end_row, end_col, root_start_row, root_start_col) < 0 then
    return {}
  end

  if cmp_position(root_end_row, root_end_col, start_row, start_col) < 0 then
    return {}
  end

  if cmp_position(start_row, start_col, root_start_row, root_start_col) <= 0 and
      cmp_position(root_end_row, root_end_col, end_row, end_col) <= 0 then
    return { root }
  end

  local nodes = {}

  for i = 0, root:child_count() - 1, 1 do
    local child = root:child(i)
    table.insert(nodes, get_nodes_in_range_impl(child, start_row, start_col,
                                                end_row, end_col))
  end

  return vim.tbl_flatten(nodes)
end

function M.get_nodes_in_range(winnr, start_row, start_col, end_row, end_col)
  local bufnr = A.nvim_win_get_buf(winnr)

  local root_lang_tree = parsers.get_parser(bufnr)
  if root_lang_tree == nil then
    return nil
  end

  local root = ts_utils.get_root_for_position(start_row, start_col,
                                              root_lang_tree)
  if root == nil then
    return nil
  end

  return get_nodes_in_range_impl(root, start_row, start_col, end_row, end_col)
end

---@param root tsnode
---@return string
function M.inspect_node(root)
  if root == nil then
    return 'nil'
  end

  local start_row, start_col, end_row, end_col = ts_utils.get_node_range(root)

  local res = '' .. root:type()
  res = res .. ' [' .. start_row .. ', ' .. start_col .. ']'
  res = res .. ' [' .. end_row .. ', ' .. end_col .. ']'

  return res
end

return M
