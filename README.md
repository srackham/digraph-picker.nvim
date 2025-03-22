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

## Implementation

- The builtin digraph definitions were scraped from the Vim help file (see `:h digraphs.txt` command).

## Todo

- Expand the installation notes.
- Document digraph addition, deletion and modification.
- Document API in this README.
- Add API documentation in the form of a Vim help file.
