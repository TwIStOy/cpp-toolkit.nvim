local M = {}

local ts_util = require("nvim-treesitter.ts_utils")
local Util = require("cpp-toolkit.util")
local UtilStr = require("cpp-toolkit.util.str")
local TPL = require("cpp-toolkit.treesitter.signature.template")
local FUNC = require("cpp-toolkit.treesitter.signature.function")
local CLS = require("cpp-toolkit.treesitter.signature.class")
local opts = require("cpp-toolkit.config").opts

---@type CppFunctionSignature
local function_declaration_base = {}

---@param self CppFunctionSignature
---@return string[]|nil
function function_declaration_base.to_lines(self)
  if self.return_type.has_placehoder and #self.return_type.text == 0 then
    -- warning
    vim.notify(
      "[CppToolkit] Declaration use placehoder return type can't generate defination.",
      vim.log.levels.WARN
    )
    return nil
  end

  local lines = {}
  if self.classes ~= nil then
    for _, cls in ipairs(self.classes) do
      if cls.template ~= nil then
        table.insert(lines, cls.template:to_line())
      end
    end
  end
  if self.template ~= nil then
    table.insert(lines, self.template:to_line())
  end

  local func_name_line = ""
  for _, storage_specifier in ipairs(self.return_type.storage_specifiers) do
    if storage_specifier ~= "static" then
      -- skip 'static', because it can not be used in function's definition
      func_name_line = UtilStr.space_concat(func_name_line, storage_specifier)
    end
  end

  if #self.return_type.text > 0 then
    if opts.impl_return_type_style == "beginning" then
      func_name_line =
        UtilStr.space_concat(func_name_line, self.return_type.text)
    else
      func_name_line = UtilStr.space_concat(func_name_line, "auto")
    end
  end

  if self.classes ~= nil then
    local cls_names = {}
    for _, cls in ipairs(self.classes) do
      table.insert(cls_names, cls:as_name())
    end
    func_name_line = UtilStr.space_concat(
      func_name_line,
      table.concat(cls_names, "::") .. "::"
    )
  end

  func_name_line = UtilStr.space_concat(func_name_line, self.body)
  if self.qualifiers ~= nil then
    func_name_line =
      UtilStr.space_concat(func_name_line, table.concat(self.qualifiers, " "))
  end

  if #self.return_type.text > 0 then
    if opts.impl_return_type_style ~= "beginning" then
      func_name_line = UtilStr.space_concat(func_name_line, "->")
      func_name_line =
        UtilStr.space_concat(func_name_line, self.return_type.text)
    end
  end
  table.insert(lines, UtilStr.trim(func_name_line) .. " {")
  table.insert(lines, "  // TODO: impl")
  table.insert(lines, "}")

  local result = {}
  for _, line in ipairs(lines) do
    -- split line with newline
    vim.list_extend(result, UtilStr.split_lines(line))
  end

  return result
end

---@param node TSNode
---@return string
local function function_declaration_body(node)
  local declarator = Util.get_node_field(node, "declarator")[1]
  local parameters = Util.get_node_field(node, "parameters")[1]
  return Util.get_node_text(declarator) .. Util.get_node_text(parameters)
end

---@param node TSNode
---@return string[]
local function function_declaration_qualifiers(node)
  local parameters = Util.get_node_field(node, "parameters")[1]
  local after_parameters = false
  local res = {}
  for c in node:iter_children() do
    if not after_parameters then
      if c:id() == parameters:id() then
        after_parameters = true
      end
    else
      if c:type() == "trailing_return_type" then
        break
      end
      res[#res + 1] = Util.get_node_text(c)
    end
  end
  return res
end

---@return CppFunctionSignature|nil
function M.function_declaration_at_cursor()
  local node = ts_util.get_node_at_cursor()
  if node == nil then
    return nil
  end

  local declaration_node = Util.find_first_parent(node, {
    "field_declaration",
    "declaration",
  })

  if declaration_node == nil then
    return nil
  end

  ---@type CppFunctionSignature
  local function_declaration = {}

  local tpl_node =
    Util.find_first_parent(declaration_node, "template_declaration")
  if tpl_node ~= nil then
    function_declaration.template = TPL.get_template_info(tpl_node)
  end
  function_declaration.return_type = FUNC.get_return_type_info(declaration_node)
  function_declaration.classes = CLS.get_recursive_class(declaration_node)
  local function_declarator_node =
    Util.dfs_find_child(declaration_node, "function_declarator")
  function_declaration.body =
    function_declaration_body(function_declarator_node)
  -- qualifier after 'parameters' and before 'trailing_return_type' if exists
  function_declaration.qualifiers =
    function_declaration_qualifiers(function_declarator_node)

  return setmetatable(
    function_declaration,
    { __index = function_declaration_base }
  )
end

return M
