local M = {}

local C = require 'cpp-toolkit.config'

function M.setup(_opts)
  local opts = vim.tbl_extend('force', C.default_opts, _opts or {})
  C.opts = opts

  if opts.cmd then
    vim.api.nvim_create_user_command('CppGenDef', function()
      require'cpp-toolkit.functions.gen_def'.gen_function_declaration_at_cursor()
    end, { bang = true })
    vim.api.nvim_create_user_command('CppDebugPrint', function()
      require'cpp-toolkit.functions.debugprint'.debugprint_at_cursor()
    end, { bang = true })
  end
end

return M
