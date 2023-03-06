local M = {}

-- get the current visual selection range
M.visual_selection_range = function()
  local _, csrow, cscol = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos "'>")

  local start_row, start_col, end_row, end_col

  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    start_row = csrow
    start_col = cscol
    end_row = cerow
    end_col = cecol
  else
    start_row = cerow
    start_col = cecol
    end_row = csrow
    end_col = cscol
  end

  return {
    st = { row = start_row, col = start_col },
    ed = { row = end_row, col = end_col },
  }
end

return M
