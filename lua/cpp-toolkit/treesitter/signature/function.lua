local M = {}

local UtilTs = require("cpp-toolkit.util.ts")
local UtilStr = require("cpp-toolkit.util.str")

---@param node TSNode
---@return string|nil
local function get_trailing_return_type(node)
  assert(node:type() == "function_declarator")

  local type_node = UtilTs.dfs_find_child(node, "trailing_return_type", nil, 1)
  if type_node == nil then
    return nil
  end
  type_node = UtilTs.dfs_find_child(type_node, "type_descriptor", nil, 1)
  if type_node == nil then
    return nil
  end
  return UtilTs.get_node_text(type_node)
end

---@param node TSNode
---@return table
local function visit_node_as_return_type_part(node)
  if node == nil then
    return {}
  end

  local ntype = node:type()

  if ntype == "function_declarator" then
    -- end
    return {}
  end

  local res = {}

  if ntype == "qualified_identifier" then
    local scope_node = UtilTs.get_node_field(node, "scope")[1]
    local scope = ""
    if scope_node ~= nil then
      scope = UtilTs.get_node_text(scope_node)
    end
    table.insert(res, string.format("%s::", scope))
  end

  if ntype == "primitive_type" then
    -- builtin type's name
    table.insert(res, UtilTs.get_node_text(node))
  end

  if ntype == "pointer_declarator" then
    -- pointer
    table.insert(res, "*")
  end

  if ntype == "reference_declarator" then
    -- reference
    table.insert(res, UtilTs.get_node_text(node:child(0)))
  end

  for c in node:iter_children() do
    local ctype = c:type()
    if ctype == "type_identifier" or ctype == "type_qualifier" then
      table.insert(res, UtilTs.get_node_text(c))
    else
      table.insert(res, visit_node_as_return_type_part(c))
    end
  end

  return res
end

---@class ReturnTypeInfo
---@field has_placehoder boolean
---@field text string
---@field storage_specifiers string[]
local ReturnTypeInfo = {}

---@param node TSNode
---@return ReturnTypeInfo
function M.get_return_type_info(node)
  local prefix = ""
  local declarator = UtilTs.get_node_field(node, "declarator")[1]

  local storage_class_specifiers = {}

  -- merge all children before `declarator`
  for c in node:iter_children() do
    if c:id() == declarator:id() then
      break
    end
    if c:type() == "storage_class_specifier" then
      table.insert(storage_class_specifiers, UtilTs.get_node_text(c))
    else
      prefix = prefix .. " " .. UtilTs.get_node_text(c)
    end
  end
  prefix = UtilStr.trim(prefix)

  ---@type ReturnTypeInfo
  local res = {
    has_placehoder = false,
    text = "",
    storage_specifiers = storage_class_specifiers,
  }

  if prefix == "auto" then
    -- if full placehoder, try to find trailing return type
    res.has_placehoder = true
    local function_node = UtilTs.dfs_find_child(node, "function_declarator")
    assert(function_node ~= nil)
    res.text = get_trailing_return_type(function_node) or ""
  else
    -- type at the beginning
    res.text = prefix
      .. table.concat(
        vim.tbl_flatten(visit_node_as_return_type_part(declarator)),
        " "
      )
  end

  return res
end

return M
