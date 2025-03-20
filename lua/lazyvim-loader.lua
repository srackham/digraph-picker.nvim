return {
  'your-username/telescope-digraphs.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('telescope').load_extension('digraphs')
    require('telescope-digraphs').setup({
      digraphs = {
        { digraph = 'SM', char = '☺', name = 'SMILING FACE' },
        { digraph = 'FR', char = '☹', name = 'FROWNING FACE' },
        { digraph = 'HT', char = '♥', name = 'HEART' },
        { digraph = 'ST', char = '★', name = 'STAR' },
      }
    })
  end
}
