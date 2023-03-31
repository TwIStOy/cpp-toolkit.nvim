local M = {}

local Path = require('plenary.path')
local Job = require 'plenary.job'
local LDB = require 'cpp-toolkit.loaders.db'
local LIH = require 'cpp-toolkit.loaders.include_hint'
local R = require 'cpp-toolkit.rooter'
local C = require 'cpp-toolkit.config'

local function try_load_db(_root)
  local root = Path.new(_root)

  local path = root / "compile_commands.json"
  if path:exists() then
    local succ, value = pcall(LDB.parse_db, vim.fn.resolve(tostring(path)))

    if succ then
      return value
    end
  end

  path = root / "build" / "compile_commands.json"
  if path:exists() then
    local succ, value = pcall(LDB.parse_db, vim.fn.resolve(tostring(path)))

    if succ then
      return value
    end
  end

  return nil
end

local function try_load_include_hint(_root)
  local root = Path.new(_root)

  local path = root / ".include_hint"

  if not path:exists() then
    return nil
  end

  local succ, value = pcall(LIH.parse_include_hint,
                            vim.fn.resolve(tostring(path)))
  if succ then
    return value
  end

  return nil
end

local Includer = {}
local Includers = {}

local function get_includes(self, filename)
  local ures = {}
  for _, source in ipairs(self.sources) do
    for _, p in ipairs(source:get_includes(filename)) do
      ures[p] = true
    end
  end
  local res = {}
  for k, _ in pairs(ures) do
    table.insert(res, k)
  end
  return res
end

function Includer.new(root)
  local sources = {}
  local db = try_load_db(root)
  local ih = try_load_include_hint(root)
  if db ~= nil then
    table.insert(sources, db)
  end
  if ih ~= nil then
    table.insert(sources, ih)
  end
  local obj = { sources = sources, get_includes = get_includes }
  return obj
end

function M.get_includer(root)
  if Includers[root] ~= nil then
    return Includers[root]
  end
  Includers[root] = Includer.new(root)
  return Includers[root]
end

function M.get_includes(root, filename)
  local includer = M.get_includer(root)
  return includer:get_includes(filename)
end

function M.get_current_includes()
  local root = R.get_resolved_root()
  if root == nil then
    return {}
  end
  return M.get_includes(root, vim.fn.expand('%:p'))
end

local function build_find_args(directory)
  local res = { '-LI' }
  for _, ext in ipairs(C.opts.header_exts) do
    table.insert(res, '-e')
    table.insert(res, ext)
  end
  table.insert(res, '--base-directory')
  table.insert(res, directory)
  return res
end

local function directory_result(directory)
  local code = 0
  local stdout = {}
  Job:new({
    command = 'fd',
    args = build_find_args(directory),
    cwd = directory,
    on_exit = function(j, return_val)
      code = return_val
    end,
    on_stdout = function(err, line)
      table.insert(stdout, line)
    end,
  }):sync()
  if code ~= 0 then
    return {}
  end
  return stdout
end

function M.list_header_files()
  local headers = {}
  local includes = M.get_current_includes()
  for _, dir in ipairs(includes) do
    local files = directory_result(dir)
    local root = Path.new(dir)
    for _, f in ipairs(files) do
      local p = tostring(root / f)
      if headers[p] == nil then
        headers[p] = f
      elseif #headers[p] < #f then
        headers[p] = f
      end
    end
  end

  local res = {}
  for k, v in pairs(headers) do
    table.insert(res, { path = k, value = v })
  end
  return res
end

return M
