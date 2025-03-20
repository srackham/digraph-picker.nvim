local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local M = {}
local config = {
  digraphs = require('digraph-picker.digraphs')
}

-- Custom column layout for Telescope display
local function make_display(entry)
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
  -- config.digraphs = opts.digraphs or {}
end

local function debug(val)
  vim.notify(vim.inspect(val), vim.log.levels.DEBUG)
end

-- Sends string to the keyboard input buffer.
local function sendkeys(str)
  local keys = vim.api.nvim_replace_termcodes(str, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

-- Insert `text` at the cursor.
-- `mode` is the mode of the window that the text is being inserted into.
local function insert_text(text, mode)
  local buf = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1]
  local col = pos[2]
  if mode ~= 'i' then
    col = col - 1
  end
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ''
  local new_line = line:sub(1, col) .. text .. line:sub(col + 1)
  vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { new_line })
  local new_col = col + #text
  vim.api.nvim_win_set_cursor(0, { row, new_col })
  if mode == 'i' then
    sendkeys('<Esc>a') -- Move one character to the right and reenter insert-mode
  else
    sendkeys('<Esc>')
  end
end

-- `insert_digraph` opens a Telescope digraph picker and inserts the selected digraph character in to the current window.
-- Normally called when the current window is in insert mode.
function M.insert_digraph(opts)
  debug(vim.api.nvim_get_mode().mode)
  opts = opts or {}
  local mode = vim.api.nvim_get_mode().mode -- Mode of window being inserted into
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
          insert_text(symbol, mode)
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
