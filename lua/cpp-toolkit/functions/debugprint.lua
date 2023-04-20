local M = {}

local Path = require 'plenary.path'
local R = require 'cpp-toolkit.rooter'
local ts_utils = require 'nvim-treesitter.ts_utils'
local vt_preview = require 'cpp-toolkit.util.vt_preview'
local JSON = require 'cpp-toolkit.util.json'

local DEFAULT_DEBUGPRINT_TEMPLATE =
    [[std::cout << "DEBUGPRINT:" << __FILE__ << ":" << __LINE__ << ":" << __FUNCTION__ << ":" << __COUNTER__ << ": " << $VAR << std::endl;]]
local DEFAULT_DEBUGPRINT_V_TEMPLATE =
    [[std::cout << "DEBUGPRINT:" << __FILE__ << ":" << __LINE__ << ":" << __FUNCTION__ << ":" << __COUNTER__ << ": $VAR = " << $VAR << std::endl;]]

local function get_debugprint_template(verbose)
  if vim.b.cpp_toolkit_debugprint_template == nil then
    -- resolve template
    local root = R.get_resolved_root()
    if root == nil then
      return nil
    end
    local root = Path:new(root)
    local template_file = root / '.debugprint.json'
    local data = Path.read(template_file)
    if data == nil or #data == 0 then
      return nil
    end
    local doc = JSON.decode(data)
    if doc == nil then
      return nil
    end
    vim.b.cpp_toolkit_debugprint_template = doc
  end
  if vim.b.cpp_toolkit_debugprint_template ~= nil then
    if verbose then
      if vim.b.cpp_toolkit_debugprint_template.verbose ~= nil then
        return vim.b.cpp_toolkit_debugprint_template.verbose
      end
    else
      if vim.b.cpp_toolkit_debugprint_template.default ~= nil then
        return vim.b.cpp_toolkit_debugprint_template.default
      end
    end
  end
  return nil
end

local function default_template(verbose)
  if verbose then
    return DEFAULT_DEBUGPRINT_V_TEMPLATE
  else
    return DEFAULT_DEBUGPRINT_TEMPLATE
  end
end

function M.debugprint(verbose)
  local template = get_debugprint_template(verbose)
  if template ~= nil and type(template) ~= "string" then
    vim.notify("[cpp-toolkit.nvim]: debugprint template is not a string",
               vim.log.levels.WARN)
  end

  if template == nil or type(template) ~= "string" then
    template = default_template(verbose)
  end

  local node = ts_utils.get_node_at_cursor()

  if node:type() ~= 'identifier' then
    return
  end

  local text = vim.treesitter.get_node_text(node, 0)
  return string.gsub(template, "$VAR", text)
end

function M.debugprint_at_cursor(...)
  local text = M.debugprint(...)
  if text ~= nil then
    local lines = {}
    for l in text:gmatch("[^\r\n]+") do
      table.insert(lines, l)
    end
    local vt = vt_preview.new_vt_preview(lines)
    vt:mount()
  end
end

return M
