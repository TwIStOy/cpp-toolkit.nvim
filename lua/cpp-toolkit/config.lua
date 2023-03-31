local M = {}

M.default_opts = {
  switch_header_source = {
    ext_mapping = {
      h = { 'c', 'cpp', 'cc', 'cxx' },
      hh = { 'cc', 'cpp', 'cxx', 'c' },
      hpp = { 'cpp', 'cxx', 'cc', 'c' },
      hxx = { 'cxx', 'cpp', 'cc', 'c' },
      c = { 'h', 'hpp', 'hh', 'hxx' },
      cc = { 'hh', 'hpp', 'hxx', 'h' },
      cpp = { 'hpp', 'hh', 'hxx', 'h' },
      cxx = { 'hxx', 'hpp', 'hh', 'h' },
    },
  },

  -- ext for header files used in include-headers
  header_exts = { 'h', 'hh', 'hpp', 'hxx' },

  -- marker to identify project root
  project_markers = { 'Makefile', 'compile_commands.json', 'CMakeLists.txt' },

  -- create user command or not
  cmd = true,

  -- highlight group for preview
  impl_preview_highlight = 'Comment',
}

M.opts = vim.deepcopy(M.default_opts)

return M
