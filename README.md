# Digraph Picker

A Neovim Telescope extension plugin for browsing and inserting digraphs.

![Screenshot](screenshot-1.png)

## Installation

- Install from the Github [srackham/digraph-picker.nvim](https://github.com/srackham/digraph-picker.nvim) repo using your preferred Neovim plugin installer.
- Call the module `setup` function from you plugin configuration e.g.

        require('digraph-picker').setup()

- Create an insert-mode keyboard mapping to invoke the digraph picker e.g.

        vim.keymap.set('i', '<C-k><C-k>', require('digraph-picker').insert_digraph,
            { noremap = true, silent = true, desc = "Digraph picker" })

### LazyVim Installation
If you use the [LazyVim](https://www.lazyvim.org/) package manager:

1. Create a Lua file (e.g. `digraph-picker.lua`) in the plugins configuration directory (normally `~/.config/nvim/lua/plugins/` on Linux) and add the following text:
   ```lua
   return {
     'srackham/digraph-picker.nvim',
     dependencies = {
       'nvim-telescope/telescope.nvim',
     },
     config = function()
       local picker = require('digraph-picker')
       picker.setup()
       vim.keymap.set('i', '<C-k><C-k>', picker.insert_digraph,
         { noremap = true, silent = true, desc = "Digraph picker" })
     end,
   }
   ```
2. Restart Neovim.

## Usage

- The recommended `<C-k><C-k>` digraph picker insert-mode key mapping plays nicely with the native Vim `<C-k>{char1}{char2}` digraph command.
- Custom digraphs are added to Neovim's internal digraph table and can be entered with the native Vim `CTRL-K {char1} {char2}` commands.

## Implementation

- The builtin digraph definitions were scraped from the Vim help file (see `:h digraph.txt` command).

## Todo

- Expand the installation notes.
- Add a _Usage_ section.
- Document digraph addition, deletion and modification.
- Document API in this README.
- Add API documentation in the form of a Vim help file.
- FIX: If the user cancels (e.g. presses Esc) when in insert mode then return to insert mode.
