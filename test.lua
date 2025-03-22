local picker = require 'digraph-picker'
local digraphs = {
  { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  { digraph = 'FR', symbol = '☹', name = 'FROWNING FACE' },
  { digraph = 'HT', symbol = '♥', name = 'HEART' },
  { digraph = 'ST', symbol = '★', name = 'STAR' },
  { digraph = 'CK', symbol = '✓', name = 'CHECK MARK' },
  { digraph = 'XX', symbol = '✗', name = 'CROSS MARK' },
  { digraph = 'SN', symbol = '☃', name = 'SNOWMAN' },
  { digraph = 'SU', symbol = '☀', name = 'SUN' },
  { digraph = 'MN', symbol = '☽', name = 'MOON' },
  { digraph = 'CL', symbol = '☁', name = 'CLOUD' },
  { digraph = 'UM', symbol = '☂', name = 'UMBRELLA' },
  { digraph = 'FL', symbol = '⚑', name = 'FLAG' },
  { digraph = 'WR', symbol = '✎', name = 'PENCIL' },
  { digraph = 'SC', symbol = '✂', name = 'SCISSORS' },
  { digraph = 'TM', symbol = '™', name = 'TRADEMARK' },
  { digraph = 'CO', symbol = '©', name = 'COPYRIGHT' },
  { digraph = 'RG', symbol = '®', name = 'REGISTERED' },
  { digraph = 'DG', symbol = '°', name = 'DEGREE' },
  { digraph = 'PI', symbol = 'π', name = 'PI' },
  { digraph = 'IN', symbol = '∞', name = 'INFINITY' },
  { digraph = 'DG', symbol = '†', name = 'DAGGER' },
  { digraph = 'EL', symbol = '…', name = 'ELLIPSIS' },
  { digraph = 'EM', symbol = '—', name = 'EM DASH' },
  { digraph = 'NE', symbol = '≠', name = 'NOT EQUAL' },
  { digraph = 'OK', symbol = '✓', name = 'CHECK MARK' },
  { digraph = 'VE', symbol = '⋮', name = 'VERTICAL ELLIPSIS' },
  { digraph = 'RA', symbol = '→', name = 'RIGHT ARROW' },
  { digraph = 'LA', symbol = '←', name = 'LEFT ARROW' },
  { digraph = 'UA', symbol = '↑', name = 'UP ARROW' },
  { digraph = 'DA', symbol = '↓', name = 'DOWN ARROW' },
  { digraph = 'LQ', symbol = '“', name = 'LEFT DOUBLE QUOTE' },
  { digraph = 'RQ', symbol = '”', name = 'RIGHT DOUBLE QUOTE' },
  { digraph = 'BU', symbol = '•', name = 'BULLET' },
  { digraph = 'PL', symbol = '±', name = 'PLUS MINUS' },
  { digraph = 'SQ', symbol = '√', name = 'SQUARE ROOT' },
  { digraph = 'AE', symbol = '≈', name = 'APPROXIMATELY EQUAL' },
  { digraph = 'LE', symbol = '≤', name = 'LESS THAN OR EQUAL' },
  { digraph = 'GE', symbol = '≥', name = 'GREATER THAN OR EQUAL' },
  { digraph = "PP", symbol = "¶", name = "PARAGRAPH SIGN" },
}
picker.setup({
  digraphs = digraphs,
  -- exclude_builtin_digraphs = true,
})

vim.keymap.set({ 'i', 'n' }, '<C-k><C-k>', function()
  picker.insert_digraph()
end, { noremap = true, silent = true, desc = "List digraphs" })

-- picker.validate_digraphs(digraphs)
