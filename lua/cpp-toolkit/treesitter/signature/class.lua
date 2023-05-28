local M = {}

local UtilTs = require("cpp-toolkit.util.ts")
local SigTpl = require("cpp-toolkit.treesitter.signature.template")

local CLASS_NODE_TYPES = { struct_specifier = 1, class_specifier = 1 }

---@type CppClass
local class_info_base = {}
---@param self CppClass
---@return string
function class_info_base.as_name(self)
  if self.template == nil then
    return self.name
  end
  local tpl_params = {}
  for _, param in ipairs(self.template.parameters) do
    table.insert(tpl_params, param.identifier)
  end
  return string.format("%s<%s>", self.name, table.concat(tpl_params, ", "))
end

---@param class_node TSNode
---@return CppClass
function M.get_class_info(class_node)
  assert(CLASS_NODE_TYPES[class_node:type()] ~= nil)

  ---@type CppClass
  local class_sig = { name = "", template = nil, is_specialization = false }

  local name_node = UtilTs.get_node_field(class_node, "name")[1]
  class_sig.name = UtilTs.get_node_text(name_node)

  local template_node =
    UtilTs.find_first_parent(class_node, "template_declaration")
  if template_node ~= nil then
    class_sig.template = SigTpl.get_template_info(template_node)
    if name_node:type() == "type_identifier" then
      class_sig.is_specialization = false
    else
      class_sig.is_specialization = true
    end
  end

  return setmetatable(class_sig, { __index = class_info_base })
end

---@param node TSNode
---@return CppClass[]|nil
function M.get_recursive_class(node)
  if node == nil then
    return nil
  end

  local p = M.get_recursive_class(node:parent())
  if CLASS_NODE_TYPES[node:type()] then
    if p == nil then
      p = {}
    end
    table.insert(p, M.get_class_info(node))
  end

  return p
end

return M
