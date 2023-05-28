local M = {}

local UtilTs = require("cpp-toolkit.util.ts")

local DEFAULT_TYPENAME_IDENTIFIER = "_Ty"

local template_signature_base = {}
---@param self CppTemplate
---@return string
function template_signature_base.to_line(self)
  local parameters = {}
  for _, p in ipairs(self.parameters) do
    table.insert(parameters, p.text)
  end
  return string.format("template<%s>", table.concat(parameters, ", "))
end

---@param node TSNode
---@return CppTemplateParameter
local function type_parameter_declaration(node)
  assert(node:type() == "type_parameter_declaration")

  local text = UtilTs.get_node_text(node)
  local identifier_node = UtilTs.dfs_find_child(node, "type_identifier", nil, 1)
  local identifier

  if identifier_node == nil then
    identifier = DEFAULT_TYPENAME_IDENTIFIER
    text = text .. " " .. identifier
  else
    identifier = UtilTs.get_node_text(identifier_node)
  end

  return { text = text, identifier = identifier }
end

---@param node TSNode
---@return CppTemplateParameter
local function parameter_declaration(node)
  assert(node:type() == "parameter_declaration")

  local text = UtilTs.get_node_text(node)
  local declarator_node = UtilTs.get_node_field(node, "declarator")[1]
  local identifier

  if declarator_node == nil then
    text = text .. "V"
    identifier = "V"
  else
    identifier = UtilTs.get_node_text(declarator_node)
  end

  return { text = text, identifier = identifier }
end

---@param node TSNode
---@return CppTemplate|nil
function M.get_template_info(node)
  if node == nil then
    return nil
  end
  local parameters_node = UtilTs.get_node_field(node, "parameters")[1]
  local parameters = {}
  for c in parameters_node:iter_children() do
    if c:type() == "type_parameter_declaration" then
      table.insert(parameters, type_parameter_declaration(c))
    elseif c:type() == "parameter_declaration" then
      table.insert(parameters, parameter_declaration(c))
    end
  end
  local info = { parameters = parameters }
  return setmetatable(info, { __index = template_signature_base })
end

return M
