local M = {}

function M.setup()
  vim.api.nvim_create_user_command('CppGenDef', function()
    require'cpp-toolkit.treesitter'.copy_function_declaration_at_cursor()
  end, { bang = true })
end

return M
