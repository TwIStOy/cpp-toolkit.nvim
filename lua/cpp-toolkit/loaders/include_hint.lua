local M = {}

local Path = require('plenary.path')

local function get_includes(self, filename)
  return self.data
end

function M.parse_include_hint(filename)
  local file = Path.new(filename)
  if file == nil then
    return nil
  end

  local root = Path.new(file:parent():asbolute())
  local lines = Path.readlines(file)
  local data = {}
  for _, line in ipairs(lines) do
    local p = Path.new(line)
    if p:is_absolute() then
      table.insert(data, tostring(p))
    else
      table.insert(data, root / p)
    end
  end

  return { data = data, get_includes = get_includes }
end

return M

