local M = {}

---comment filter
---@param arr Array
---@param func function
---@return Array
function M.filter(arr, func)
  vim.validate {
    arr = { arr, vim.tbl_islist, 'list' },
    func = { func, 'function' },
  }

  local res = {}
  for _, v in ipairs(arr) do
    if func(v) then
      table.insert(res, v)
    end
  end
  return res
end

---comment
---@param arr Array
---@param func function
---@return Array
function M.transform(arr, func)
  vim.validate {
    arr = { arr, vim.tbl_islist, 'list' },
    func = { func, 'function' },
  }

  local res = {}
  for _, v in ipairs(arr) do
    local n = func(v)
    if n ~= nil then
      table.insert(res, n)
    end
  end

  return res
end

return M
