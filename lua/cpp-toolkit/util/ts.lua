local M = {}

local parsers = require 'nvim-treesitter.parsers'
local TSRange = require'nvim-treesitter.tsrange'.TSRange
local ts_utils = require 'nvim-treesitter.ts_utils'
local A = vim.api

---@param types table | string
---@return table<string, number>
local function make_type_matcher(types)
  if type(types) == 'string' then
    return { [types] = 1 }
  end

  if type(types) == 'table' then
    if vim.tbl_islist(types) then
      local new_types = {}
      for _, v in ipairs(types) do
        new_types[v] = 1
      end
      return new_types
    end
  end

  return types
end

---Get the text of a node.
---@param node TSNode
---@return string
function M.get_node_text(node)
  return vim.treesitter.get_node_text(node, 0)
end

---Recursive find the topmost parent node whose type matches `types`.
---@param node TSNode
---@param types table<string, number> | string
---@return TSNode | nil
function M.find_topmost_parent(node, types)
  local ntypes = make_type_matcher(types)

  ---@param root TSNode
  ---@return TSNode | nil
  local function find_parent_impl(root)
    if root == nil then
      return nil
    end
    local res = nil
    if ntypes[root:type()] then
      res = root
    end
    return find_parent_impl(root:parent()) or res
  end

  return find_parent_impl(node)
end

---Recursive find the first parent node whose type matches `types`.
---@param node TSNode
---@param types table<string, number> | string
---@return TSNode | nil
function M.find_first_parent(node, types)
  local ntypes = make_type_matcher(types)

  ---@param root TSNode
  ---@return TSNode | nil
  local function find_parent_impl(root)
    if root == nil then
      return nil
    end
    if ntypes[root:type()] then
      return root
    end
    return find_parent_impl(root:parent())
  end

  return find_parent_impl(node)
end

---Find the first child node whose type matches `types` using DFS.
---@param node TSNode
---@param types table | string
---@param pruning TSNode | nil
---@param max_depth number | nil
function M.dfs_find_child(node, types, pruning, max_depth)
  local ntypes = make_type_matcher(types)

  ---@param root TSNode
  ---@param depth number
  ---@return TSNode | nil
  local function dfs_child_impl(root, depth)
    if root == nil then
      return nil
    end
    if max_depth ~= nil and depth > max_depth then
      return nil
    end
    if ntypes[root:type()] then
      return root
    end
    for c in root:iter_children() do
      if pruning == nil or pruning[c:type()] then
        local r = dfs_child_impl(c, depth + 1)
        if r ~= nil then
          return r
        end
      end
    end
    return nil
  end

  return dfs_child_impl(node, 0)
end

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

---@return string
function M.inspect_node_under_cursor()
  local root = ts_utils.get_node_at_cursor()
  return M.inspect_node(root)
end

---@param root TSNode
---@return string
function M.inspect_node(root)
  if root == nil then
    return 'nil'
  end

  local start_row, start_col, end_row, end_col =
      vim.treesitter.get_node_range(root)

  local res = '' .. root:type()
  res = res .. ' [' .. start_row .. ', ' .. start_col .. ']'
  res = res .. ' [' .. end_row .. ', ' .. end_col .. ']'

  return res
end

---Get the range of a node in LSP format.
---@param node TSNode
function M.get_lsp_range(node)
  local start_row, start_col, end_row, end_col = node:range()
  return {
    start = { line = start_row, character = start_col },
    ['end'] = { line = end_row, character = end_col },
  }
end

return M
