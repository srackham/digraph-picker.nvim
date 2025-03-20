# Digraph Picker

A Neovim Telescope extension for browsing and inserting digraphs.

Inspired by [protex/better-digraphs.nvim: Better digraphs plugin](https://github.com/protex/better-digraphs.nvim).

## Implementation

### setup function
Options:

    digraphs = { <additional digraph definitions>... }
    exclude='<regexp>'  -- Exclude builtin digraphs matching the regular expression ('.*' or '..' excludes all builtin digraphs).

- The plugin's `setup` function has a `digraphs` option which is a Lua table containing digraph definitions, for example:

  ```lua
    {
      { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
      { digraph = 'FR', symbol = '☹', name = 'FROWNING FACE' },
      { digraph = 'HT', symbol = '♥', name = 'HEART' },
      { digraph = 'ST', symbol = '★', name = 'STAR' },
    }
  ```

### Perplexity Query
This Perplexity Query was the starting point:

Generate code for a neovim Telescope extension plugin that implements a Telescope picker to view a list of neovim digraphs which can then be selected and inserted into the current buffer. Here's the specification:

- The Telescope picker layout column widths are 10% for `symbol` (column 1), 10% for `digraph` (column 2), 80% for `name` (column 3).
- The plugin exposes a function called `insert_digraph` which allows the user to search digraph definition `name` and `digraph` fields
- If the user selects a digraph then the digraph `symbol` is inserted into the neovim buffer.
- Neovim is assumed to be executing in insert-mode when the `insert_digraph` function is executed.

### Perplexity Response
https://www.perplexity.ai/search/generate-code-for-a-neovim-tel-0xiAc6O1QTmtPuH7vEgz9g

## Digraph Characters

- For builtin symbols see `:h digraph.txt`
- Only include single-character digraphs from `digraph.txt`
- A collection of symbols: [nvim-telescope/telescope-symbols.nvim](https://github.com/nvim-telescope/telescope-symbols.nvim)

