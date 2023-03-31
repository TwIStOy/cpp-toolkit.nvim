local M = {}

local ts_util = require 'nvim-treesitter.ts_utils'
local Util = require 'cpp-toolkit.util'
local TPL = require 'cpp-toolkit.treesitter.signature.template'
local FUNC = require 'cpp-toolkit.treesitter.signature.function'
local CLS = require 'cpp-toolkit.treesitter.signature.class'

local function_declaration_base = {}

function function_declaration_base.to_lines(self)
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
  local prefix = ''
  if self.classes ~= nil then
    local cls_names = {}
    for _, cls in ipairs(self.classes) do
      table.insert(cls_names, cls:as_name())
    end
    prefix = table.concat(cls_names, '::') .. '::'
  end
  if self.return_type ~= nil and #self.return_type > 0 then
    table.insert(lines, string.format('auto %s%s -> %s {', prefix, self.body,
                                      self.return_type))
  else
    table.insert(lines, string.format('%s%s {', prefix, self.body))
  end
  table.insert(lines, '  // TODO: impl')
  table.insert(lines, '}')

  local result = {}
  for _, line in ipairs(lines) do
    -- split line with newline
    for l in line:gmatch("[^\r\n]+") do
      table.insert(result, l)
    end
  end

  return result
end

function M.function_declaration_at_cursor()
  local node = ts_util.get_node_at_cursor()
  if node == nil then
    return nil
  end

  local declaration_node = Util.find_first_parent(node, {
    'field_declaration',
    'declaration',
  })

  if declaration_node == nil then
    return nil
  end

  local function_declaration = {}

  local tpl_node = Util.find_first_parent(declaration_node,
                                          'template_declaration')
  if tpl_node ~= nil then
    function_declaration.template = TPL.get_template_info(tpl_node)
  end
  function_declaration.return_type = FUNC.get_return_type_info(declaration_node)
  function_declaration.classes = CLS.get_recursive_class(declaration_node)
  local function_declarator_node = Util.dfs_find_child(declaration_node,
                                                       'function_declarator')
  function_declaration.body = Util.get_node_text(function_declarator_node)

  return setmetatable(function_declaration,
                      { __index = function_declaration_base })
end

return M
