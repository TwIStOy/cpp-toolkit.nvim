local M = {}

M.opts = {}

M.opts.switch_header_source = {
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
}

M.opts.header_exts = { 'h', 'hh', 'hpp', 'hxx' }

M.opts.project_markers = { 'Makefile', 'compile_commands.json',
                           'CMakeLists.txt' }

return M
