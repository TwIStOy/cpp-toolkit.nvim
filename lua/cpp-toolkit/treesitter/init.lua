local M = {}

local Sig = require 'cpp-toolkit.treesitter.signature'
local cpp_toolkit = require 'cpp-toolkit.util.globals'
local A = vim.api
local C = require 'cpp-toolkit.config'

local cpptoolkit_copyed_function_declaration = {}
local definition_preview = {
  lines = {},
  cursor_moved_id = nil,
  previous_buffer = nil,
  ns_id = vim.api.nvim_create_namespace('cpptoolkit.definition_preview'),
  extmark_id = 1,
  keymap_set = false,
}

function definition_preview:clear_preview()
  if self.previous_buffer ~= nil then
    A.nvim_buf_del_extmark(self.previous_buffer, self.ns_id, self.extmark_id)
  end
end

function definition_preview:confirm()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row, row, true, self.lines)
end

function definition_preview:setup_keymap()
  if not self.keymap_set then
    vim.keymap.set('n', '<CR>', function()
      self:confirm()
      self:stop()
    end)

    vim.keymap.set('n', '<Esc>', function()
      self:stop()
    end)

    self.keymap_set = true
  end
end

function definition_preview:update_lines(lines)
  self.lines = lines
  self:update_preview()
  self:setup_autocmd()
  self:setup_keymap()
end

function definition_preview:setup_autocmd()
  if self.cursor_moved_id == nil then
    self.cursor_moved_id = A.nvim_create_autocmd({ 'CursorMoved',
                                                   'CursorMovedI' }, {
      group = cpp_toolkit.augroup,
      pattern = '*',
      callback = function()
        self:update_preview()
      end,
    })
  end
end

function definition_preview:update_preview()
  self:clear_preview()
  if #self.lines == 0 then
    return
  end

  local extmark = {
    id = self.extmark_id,
    virt_text_win_col = vim.fn.virtcol(".") - 1,
    virt_lines = {},
  }
  for i = 1, #self.lines do
    extmark.virt_lines[i] = { { self.lines[i], C.opts.impl_preview_highlight } }
  end

  local cursor_col = vim.fn.col(".")
  self.previous_buffer = A.nvim_win_get_buf(0)
  A.nvim_buf_set_extmark(self.previous_buffer, self.ns_id, vim.fn.line(".") - 1,
                         cursor_col - 1, extmark)
end

function definition_preview:stop()
  self:clear_preview()

  if self.cursor_moved_id ~= nil then
    A.nvim_del_autocmd(self.cursor_moved_id)
    self.cursor_moved_id = nil
  end

  if self.keymap_set then
    vim.keymap.del('n', '<CR>')
    vim.keymap.del('n', '<Esc>')
    self.keymap_set = false
  end
end

function M.copy_function_declaration_at_cursor()
  cpptoolkit_copyed_function_declaration = Sig.function_declaration_at_cursor()
  if cpptoolkit_copyed_function_declaration ~= nil then
    definition_preview:update_lines(
        cpptoolkit_copyed_function_declaration:to_lines())
  end
end

return M

