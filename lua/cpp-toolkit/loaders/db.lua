local M = {}

local json = require 'cpp-toolkit.util.json'
local UA = require 'cpp-toolkit.util.array'
local shlex = require 'cpp-toolkit.util.shlex'
local Path = require 'plenary.path'

local DB = {}

---comment
---@param file_opt table
---@return boolean
local function valid_file_options(file_opt)
  local expect_type = function(obj, ty, valid)
    return obj ~= nil and type(obj) == ty and (valid == nil or valid(obj))
  end

  return
      expect_type(file_opt, 'table') and expect_type(file_opt.file, 'string') and
          ((file_opt.arguments ~= nil and
              expect_type(file_opt.arguments, 'table', vim.tbl_islist)) or
              (file_opt.command ~= nil and
                  expect_type(file_opt.command, 'string'))) and
          expect_type(file_opt.directory, 'string')
end

---comment convert include argument to include path, return nil is not a include argument
---@param arg string
local function include_argument(arg)
  if arg:find('^-I') == nil then
    return nil
  end
  return arg:sub(3)
end

local function try_common_prefix(db, p)
  local res = {}
  for k, v in pairs(db) do
    local prefix = string.sub(k, 1, #p)
    if prefix == p then
      for _, include in ipairs(v) do
        res[include] = true
      end
    end
  end
  local includes = {}
  for k, _ in pairs(res) do
    table.insert(includes, k)
  end
  return includes
end

local function get_includes(self, file)
  if self.data[file] ~= nil then
    return self.data[file]
  end

  local function try_recursive(path)
    if tostring(path) == tostring(path:parent()) then
      return {}
    end
    local res = try_common_prefix(self.data, tostring(path))
    if #res > 0 then
      return res
    end

    return try_recursive(path:parent())
  end

  local p = Path.new(file):parent()
  return try_recursive(p)
end

function M.parse_db(filename)
  local file = Path.new(filename)
  if file == nil then
    return nil
  end
  local data = Path.read(file)
  if data == nil or #data == 0 then
    return nil
  end

  local doc = json.decode(data)
  if doc == nil then
    return nil
  end

  local data = {}
  for _, file_opts in ipairs(doc) do
    if not valid_file_options(file_opts) then
      goto continue
    end

    local source_file = Path.new(file_opts.file)
    if not source_file:is_absolute() then
      source_file = source_file:absolute()
    end
    local directory = Path.new(file_opts.directory)
    local arguments = {}
    if file_opts.arguments == nil then
      arguments = shlex.split(file_opts.command)
    else
      arguments = file_opts.arguments
    end

    local includes = UA.transform(arguments, include_argument)
    includes = UA.transform(includes, function(folder)
      local f = Path.new(folder)
      if f:is_absolute() then
        return f:expand()
      else
        local p = directory / f
        p = Path.new(p:absolute())
        assert(Path.is_path(p))
        return p:expand()
      end
    end)

    -- unique
    local ures = {}
    for _, p in ipairs(includes) do
      ures[vim.fn.resolve(tostring(p))] = true
    end
    local res = {}
    for k, _ in pairs(ures) do
      table.insert(res, k)
    end

    data[tostring(source_file)] = res

    ::continue::
  end

  local db = {}

  db.data = data
  db.get_includes = get_includes

  return db
end

return M
