local Path = require('plenary.path')
local Config = require 'cpp-toolkit.config'

local function resolve_root(filename)
  local current = Path.new(filename)
  if current:is_dir() then
    current = current:parent()
  end

  local function try_path(path)
    if tostring(path) == tostring(path:parent()) then
      return nil
    end
    for _, marker in ipairs(Config.opts.project_markers) do
      local tp = path / marker
      if tp:exists() and tp:is_file() then
        return path
      end
    end
    return try_path(path:parent())
  end

  local res = try_path(current)
  if res ~= nil then
    res = tostring(res)
  end
  return res
end

local function get_resolved_root()
  if vim.b.cpp_toolkit_resolved_root == nil then
    vim.b.cpp_toolkit_resolved_root = {
      value = resolve_root(vim.fn.expand('%:p')),
    }
  end
  return vim.b.cpp_toolkit_resolved_root.value
end

return { get_resolved_root = get_resolved_root }

