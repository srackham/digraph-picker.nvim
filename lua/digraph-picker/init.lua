local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local M = {}

-- Merges a source digraphs table (`src`) into a destination (`dst`) digraphs table. The digraphs table contains a list of digraph definitions. Here's an example of a digraphs table:
--
-- ```lua
-- {
--   { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
--   { digraph = 'FR', symbol = '☹', name = 'FROWNING FACE' },
--   { digraph = 'HT', symbol = '♥', name = 'HEART' },
--   { digraph = 'ST', symbol = '★', name = 'STAR' },
-- },
-- ```
-- The rules for merging a digraph definition into the destination table are:
--
-- - If the destination table contains a definition with the same `symbol` then non-nil definition `digraph` and `name` fields are assigned to the corresponding fields in the destination definition.
-- - If the destination table does not contain a definition with the same `symbol` then the source definition is appended to destination table.
function M.merge_digraphs(src, dst)
  local dst_symbols = {}
  for i, def in ipairs(dst) do
    dst_symbols[def.symbol] = i
  end
  for _, src_def in ipairs(src) do
    local dst_index = dst_symbols[src_def.symbol]
    if dst_index then
      local dst_def = dst[dst_index]
      if src_def.digraph then
        dst_def.digraph = src_def.digraph
      end
      if src_def.name then
        dst_def.name = src_def.name
      end
    else
      table.insert(dst, src_def)
    end
  end
end

-- `update_vim_digraphs(symbols, digraphs)` sets Vim digraphs with matching `symbols` from the `digraphs` table (see `merge_digraphs`).
function M.update_vim_digraphs(symbols, digraphs)
  local digraphs_index = {}
  for i, def in ipairs(digraphs) do
    digraphs_index[def.symbol] = i
  end
  for _, symbol in pairs(symbols) do
    local def = digraphs[digraphs_index[symbol]]
    print("Set digraph: ", def.digraph, def.symbol)
    -- vim.fn.digraph_set(def.digraph, def.symbol)
  end
end

-- `validate_digraphs(digraphs)` validates the `digraphs` table of digraph definitions (see `merge_digraphs`) and returns `true` if there are no validation errors. When an invalid digraph definition is found the user is notified with a printed error message. The validation rules are as follows:
--
-- - the `symbol` field must be a single character.
-- - the `digraph` field must be two printable characters.
-- - the `name` field must contain at least one character.
function M.validate_digraphs(digraphs)
  local function table_to_string(t)
    local parts = {}
    for k, v in pairs(t) do
      if type(v) == "string" then
        parts[#parts + 1] = k .. " = '" .. v .. "'"
      else
        parts[#parts + 1] = k .. " = " .. tostring(v)
      end
    end
    return "{ " .. table.concat(parts, ", ") .. " }"
  end

  local function print_error(index, error_message, def)
    vim.notify(
      "Error: Invalid digraph definition at index " .. index .. ": " .. error_message .. ": " .. table_to_string(def),
      vim.log.levels.ERROR)
  end

  if type(digraphs) ~= "table" then
    error("`digraphs` must be a table of digraph definitions.")
    return false
  end
  local valid = true
  for i, def in ipairs(digraphs) do
    if type(def) ~= "table" then
      vim.notify("Error: Digraph definition at index " .. i .. " is not a table.", vim.log.levels.ERROR)
      valid = false
      goto continue
    end
    if type(def.symbol) ~= "string" or vim.fn.strchars(def.symbol) ~= 1 then
      print_error(i, "Symbol must be a single character", def)
      valid = false
      goto continue
    end
    if type(def.digraph) ~= "string" or vim.fn.strchars(def.digraph) ~= 2 or not def.digraph:match("^%C%C$") then
      print_error(i, "Digraph must be two printable characters", def)
      valid = false
      goto continue
    end
    if type(def.name) ~= "string" or vim.fn.strchars(def.name) < 1 then
      print_error(i, "Name must contain at least one character", def)
      valid = false
      goto continue
    end
    ::continue::
  end
  return valid
end

-- `digraphs_deep_copy` returns a deep copy of the table of `digraphs` definitions.
local function digraphs_deep_copy(digraphs)
  local result = {}
  for i, def in ipairs(digraphs) do
    result[i] = { digraph = def.digraph, symbol = def.symbol, name = def.name }
  end
  return result
end

-- `setup` initialises and configures the plugin.
--
-- Options:
--
--   `digraphs`: A table of digraph definitions (see `merge_digraphs`).
--   `exclude_builtin_digraphs``: Setting this to `true` stops the builtin digraph table from loading.
--
function M.setup(opts)
  print("DEVELOPMENT MODE")
  opts = opts or {}
  opts.digraphs = opts.digraphs or {}
  M.digraphs = {}
  if not opts.exclude_builtin_digraphs then
    M.digraphs = digraphs_deep_copy(require('digraph-picker.digraphs'))
  end
  M.merge_digraphs(opts.digraphs, M.digraphs)
  M.validate_digraphs(M.digraphs)
  local symbols = {}
  for _, def in ipairs(opts.digraphs) do
    table.insert(symbols, def.symbol)
  end
  M.update_vim_digraphs(symbols, M.digraphs)
end

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
  end
end

-- `insert_digraph` opens a Telescope digraph picker and inserts the selected digraph character into the current window.
-- This function is normally called in insert mode.
function M.insert_digraph(opts)
  opts = opts or {}
  local mode = vim.api.nvim_get_mode().mode -- Mode of window being inserted into
  pickers.new({}, {
    prompt_title = "Insert Digraph",
    finder = finders.new_table({
      results = M.digraphs,
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
