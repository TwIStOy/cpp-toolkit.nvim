local M = {
  augroup = vim.api.nvim_create_augroup('cpptoolkit.definition_generated',
                                        { clear = true }),
  ns_id = vim.api.nvim_create_namespace('cpptoolkit.definition_generated'),
  extmark_id = 1,
}

return M
