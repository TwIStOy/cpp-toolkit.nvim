local M = {}

local Sig = require 'cpp-toolkit.treesitter.signature'

local cpptoolkit_copyed_function_declaration = {}

function M.copy_function_declaration_at_cursor()
  cpptoolkit_copyed_function_declaration = Sig.function_declaration_at_cursor()
  vim.pretty_print(cpptoolkit_copyed_function_declaration)
  vim.pretty_print(cpptoolkit_copyed_function_declaration.__metatable)
  print(cpptoolkit_copyed_function_declaration:to_lines())
end

return M

