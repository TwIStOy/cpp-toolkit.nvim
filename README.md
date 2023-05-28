# Simple toolkit for Cpp

# Installation

Requirement: Neovim Nightly

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vimscript
Plug 'TwIStOy/cpp-toolkit.nvim'
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'TwIStOy/cpp-toolkit.nvim'
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'TwIStOy/cpp-toolkit.nvim',
    cmd = {
        'CppGenDef', 'CppDebugPrint', 'CppToolkit'
    },
    dependencies = {
        'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim'
    }
}
```

# Configuration

Default values:

```lua
{
    'TwIStOy/cpp-toolkit.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    opts = {
        -- ext for header files used in include-headers
        header_exts = { 'h', 'hh', 'hpp', 'hxx' },

        -- marker to identify project root
        project_markers = { 'Makefile', 'compile_commands.json', 'CMakeLists.txt' },

        -- create user command or not
        cmd = true,

        -- highlight group for preview
        impl_preview_highlight = 'Comment',

        -- "trailing" or "beginning"
        -- signature:
        --   void foo(int bar);
        -- impl, style = "begin":
        --   void foo(int bar) {
        --   }
        -- impl, style = "trailing"
        --   auto foo(int bar) -> void {
        --   }
        impl_return_type_style = "beginning",
    }
    config = function(_, opts)
        require'cpp-toolkit'.setup(opts)
    end,
    cmd = { 'CppGenDef', 'CppDebugPrint', 'CppToolkit', 'Telescope' },
    keys = {
        {
            '<C-e><C-i>',
            function()
                vim.cmd [[Telescope cpptoolkit insert_header]]
                end,
            desc = 'insert-header',
            mode = { 'i', 'n' },
        },
    },
}
```

# Features

## Generate function impl
![](https://raw.githubusercontent.com/TwIStOy/cpp-toolkit.nvim/master/screenshots/screen_gen_cpp_impl.gif)

## Generate debug-print stmt
![](https://raw.githubusercontent.com/TwIStOy/cpp-toolkit.nvim/master/screenshots/screen_debug_print.gif)

## Generate some shortcuts for values

### `std::move`
![](https://raw.githubusercontent.com/TwIStOy/cpp-toolkit.nvim/master/screenshots/screen_shortcut_move_value.gif)

### `std::forward`
![](https://raw.githubusercontent.com/TwIStOy/cpp-toolkit.nvim/master/screenshots/screen_shortcut_forward_value.gif)

### `std::cout`
![](https://raw.githubusercontent.com/TwIStOy/cpp-toolkit.nvim/master/screenshots/screen_shortcut_stdcout_values.gif)

