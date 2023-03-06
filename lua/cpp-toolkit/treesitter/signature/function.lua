local M = {}

local UtilTs = require 'cpp-toolkit.util.ts'

---@param node TSNode
---@return table
local function visit_node_as_return_type_part(node)
  if node == nil then
    return {}
  end

  local ntype = node:type()

  if ntype == 'function_declarator' then
    -- end
    return {}
  end

  local res = {}

  if ntype == 'qualified_identifier' then
    local scope_node = node:field('scope')[1]
    local scope = ''
    if scope_node ~= nil then
      scope = UtilTs.get_node_text(scope_node)
    end
    table.insert(res, string.format('%s::', scope))
  end

  if ntype == 'primitive_type' then
    -- builtin type's name
    table.insert(res, UtilTs.get_node_text(node))
  end

  if ntype == 'pointer_declarator' then
    -- pointer
    table.insert(res, '*')
  end

  if ntype == 'reference_declarator' then
    -- reference
    table.insert(res, UtilTs.get_node_text(node:child(0)))
  end

  for c in node:iter_children() do
    local ctype = c:type()
    if ctype == 'type_identifier' or ctype == 'type_qualifier' then
      table.insert(res, UtilTs.get_node_text(c))
    else
      table.insert(res, visit_node_as_return_type_part(c))
    end
  end

  return res
end

---@param node TSNode
---@return string
function M.get_return_type_info(node)
  local type_node = node:field('type')[1]
  if type_node == nil then
    -- constructors has no `type` field
    return ''
  end

  local prefix = ''
  local declarator = node:field('declarator')[1]

  for c in node:iter_children() do
    if c:id() ~= declarator:id() then
      prefix = prefix .. ' ' .. UtilTs.get_node_text(c)
    else
      break
    end
  end

  return prefix ..
             table.concat(
                 vim.tbl_flatten(visit_node_as_return_type_part(declarator)),
                 ' ')
end

return M
