local M = {}

local Sig = require("cpp-toolkit.treesitter.signature")
local vt_preview = require("cpp-toolkit.util.vt_preview")

local cpptoolkit_copyed_function_declaration = {}
function M.gen_function_declaration_at_cursor()
  cpptoolkit_copyed_function_declaration = Sig.function_declaration_at_cursor()
  if cpptoolkit_copyed_function_declaration ~= nil then
    local lines = cpptoolkit_copyed_function_declaration:to_lines()
    if lines ~= nil then
      local preview = vt_preview.new_vt_preview()
      preview:mount()
    end
  end
end

return M
