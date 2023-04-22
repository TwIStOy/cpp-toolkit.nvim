local M = {}

local C = require 'cpp-toolkit.config'

local subcommands = {
  gen_def = function()
    require'cpp-toolkit.functions.gen_def'.gen_function_declaration_at_cursor()
  end,
  shortcut = require'cpp-toolkit.functions.shortcut'.shortcuts,
  debug_print = function()
    require'cpp-toolkit.functions.debugprint'.debugprint_at_cursor()
  end,
}

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

    vim.api.nvim_create_user_command('CppToolkit', function(args)
      local cmd = subcommands[args.fargs[1]]
      if args.fargs[1] == nil then
        vim.notify('[cpptoolkit.nvim] Require subcommands', vim.log.levels.WARN)
        return
      end
      if cmd == nil then
        vim.notify('[cpptoolkit.nvim] Unknown subcommands: ' .. args.fargs[1],
                   vim.log.levels.WARN)
        return
      end
      if type(cmd) == 'function' then
        cmd(args.fargs[2])
      end
      if type(cmd) == 'table' then
        local f = cmd[args.fargs[2]]
        if f == nil then
          vim.notify(string.format('[cpptoolkit.nvim] Unknown args %s in %s',
                                   args.fargs[2], args.fargs[1]),
                     vim.log.levels.WARN)
        else
          f()
        end
      end
    end, {
      range = false,
      nargs = '+',
      complete = function(_, line)
        local l = vim.split(line, '%s+')
        local n = #l - 2

        if n == 0 then
          return vim.tbl_filter(function(s)
            return vim.startswith(s, l[2])
          end, vim.tbl_keys(subcommands))
        end

        if n == 1 then
          local cmd = subcommands[l[2]]
          if cmd == nil then
            return {}
          end
          if type(cmd) == 'function' then
            return {}
          end
          if type(cmd) == 'table' then
            return vim.tbl_filter(function(s)
              return vim.startswith(s, l[3])
            end, vim.tbl_keys(cmd))
          end
        end
      end,
    })
  end
end

return M
