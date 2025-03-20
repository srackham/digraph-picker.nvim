local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local M = {}
local config = {
  digraphs = {}
}

-- Custom column layout for Telescope display
local make_display = function(entry)
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 0.1 },
      { width = 0.1 },
      { width = 0.8 },
    },
  })

  return displayer({
    { entry.value.symbol,  'TelescopeResultsIdentifier' },
    { entry.value.digraph, 'TelescopeResultsNumber' },
    entry.value.name,
  })
end

-- Setup function to configure plugin
function M.setup(opts)
  config.digraphs = opts.digraphs or {}
end

-- Main entry point for Telescope picker
function M.insert_digraph(opts)
  opts = opts or {}
  pickers.new({}, {
    prompt_title = "Insert Digraph",
    finder = finders.new_table({
      results = config.digraphs,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry.digraph .. ' ' .. entry.name,
        }
      end
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if selection then
          -- Insert symbol while maintaining insert mode
          local symbol = selection.value.symbol
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(symbol, true, true, true),
            'i', true
          )
        end
      end)

      return true
    end,
    layout_config = {
      width = 0.8,
      height = 0.5,
    }
  }):find()
end

return M
