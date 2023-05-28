local M = {}

function M.trim(s)
  return s:match("^()%s*$") and "" or s:match("^%s*(.*%S)")
end

function M.split_lines(s)
  local lines = {}
  for line in s:gmatch("[^\r\n]+") do
    lines[#lines + 1] = line
  end
  return lines
end

function M.space_concat(a, b)
  -- check if a ends with space
  if #a == 0 or a:sub(-1) == " " then
    return a .. b
  else
    return a .. " " .. b
  end
end

return M
