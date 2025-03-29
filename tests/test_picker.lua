--
-- Test for digraph picker functions. Run with: make test
--

local M = require('digraph-picker')
local tests_failed = false

local function is_digraph_def_equal(def1, def2)
  return def2.symbol == def1.symbol and def2.digraph == def1.digraph and def2.name == def1.name
end

-- ANSI escape codes
local green = '\027[32m' -- Start green text
local red = '\027[31m'
local reset = '\027[0m'  -- Reset all attributes (color, etc.)

local function print_passed(message)
  io.write(green .. '✔ ' .. reset .. (message or 'Test passed') .. '\n')
end

local function print_failed(expected, actual, message)
  io.write(red .. '✘ ' .. reset .. (message or 'Test failed') .. '\n')
  io.write('  Expected: ' .. vim.inspect(expected) .. '\n')
  io.write('  Actual:   ' .. vim.inspect(actual) .. '\n')
  tests_failed = true
end

local function assert_equal(expected, actual, message)
  if expected == actual then
    print_passed(message)
  else
    print_failed(expected, actual, message)
  end
end

local function assert_starts_with(expected, actual, message)
  if string.sub(actual, 1, string.len(expected)) == expected then
    print_passed(message)
  else
    print_failed(expected, actual, message)
  end
end

local function assert_digraph_defs_equal(expected, actual, message)
  if is_digraph_def_equal(expected, actual) then
    print_passed(message)
  else
    print_failed(expected, actual, message)
  end
end

local function assert_digraphs_tables_equal(expected, actual, message)
  if #expected ~= #actual then
    print_failed(expected, actual, message)
    return
  end
  local is_equal = true
  for i, _ in ipairs(expected) do
    if not is_digraph_def_equal(expected[i], actual[i]) then
      print_failed(expected, actual, (message or "Test failed") .. ": at index " .. i)
      return
    end
  end
  print_passed(message)
end

-- Tests for validate_digraphs
local function test_validate_digraphs()
  local valid_digraphs = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
    { digraph = 'FR', symbol = '☹', name = 'FROWNING FACE' },
  }
  assert_equal(nil, M.validate_digraphs(valid_digraphs), "validate_digraphs: valid digraphs")

  local invalid_digraphs_1 = {
    { digraph = 'S', symbol = '☺', name = 'SMILING FACE' },
  }
  assert_starts_with(
    'invalid digraph definition at index 1: digraph must be two printable characters:',
    M.validate_digraphs(invalid_digraphs_1), "validate_digraphs: invalid digraph length")

  local invalid_digraphs_2 = {
    { digraph = 'SM', symbol = 'aa', name = 'SMILING FACE' },
  }
  assert_starts_with(
    'invalid digraph definition at index 1: symbol must be a single character:',
    M.validate_digraphs(invalid_digraphs_2), "validate_digraphs: invalid symbol length")

  local invalid_digraphs_3 = {
    { digraph = 'SM', symbol = '☺', name = '' },
  }
  assert_starts_with(
    'invalid digraph definition at index 1: name must contain at least one character:',
    M.validate_digraphs(invalid_digraphs_3), "validate_digraphs: empty name")

  local invalid_digraphs_4 = {
    { digraph = 'SM', symbol = '☺', name = 'valid' },
    'not a table',
  }
  assert_equal('invalid digraph definition at index 2: digraph is not a table: "not a table"',
    M.validate_digraphs(invalid_digraphs_4), "validate_digraphs: not a table in table")

  local invalid_digraphs_5 = 'not a table'
  assert_equal('`digraphs` must be a table of digraph definitions', M.validate_digraphs(invalid_digraphs_5),
    "validate_digraphs: not a table")

  local invalid_digraphs_6 = {
    { digraph = 'SM', symbol = '☺', name = 'valid' },
    { digraph = '12', symbol = 'a', name = 'valid' },
    { digraph = '12', symbol = 'a', name = '' },
    { digraph = '12', symbol = 'a', name = 'valid' },
  }
  local result = M.validate_digraphs(invalid_digraphs_6)
  assert_equal('invalid digraph definition at index 3: name must contain at least one character:',
    result:match('invalid digraph definition at index 3: name must contain at least one character:'),
    "validate_digraphs: multiple errors")
end

-- Tests for merge_digraphs
local function test_merge_digraphs()
  local dst = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
    { digraph = 'FR', symbol = '☹', name = 'FROWNING FACE' },
  }
  local src = {
    { digraph = 'HT', symbol = '♥', name = 'HEART' },
    { digraph = 'SM', symbol = '☺', name = 'NEW SMILING FACE' },
  }
  local expected = {
    { digraph = 'SM', symbol = '☺', name = 'NEW SMILING FACE' },
    { digraph = 'FR', symbol = '☹', name = 'FROWNING FACE' },
    { digraph = 'HT', symbol = '♥', name = 'HEART' },
  }
  M.merge_digraphs(src, dst)
  assert_digraphs_tables_equal(expected, dst, "merge_digraphs: basic merge")

  local dst2 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }
  local src2 = {
    { symbol = '☺' },
  }
  local expected2 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }
  M.merge_digraphs(src2, dst2)
  assert_digraphs_tables_equal(expected2, dst2, "merge_digraphs: merge with partial src def")

  local dst3 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }
  local src3 = {
    { digraph = 'HT', symbol = '♥', name = 'HEART' },
  }
  local expected3 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
    { digraph = 'HT', symbol = '♥', name = 'HEART' },
  }
  M.merge_digraphs(src3, dst3)
  assert_digraphs_tables_equal(expected3, dst3, "merge_digraphs: append new entry")

  local dst4 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }
  local src4 = {}
  local expected4 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }
  M.merge_digraphs(src4, dst4)
  assert_digraphs_tables_equal(expected4, dst4, "merge_digraphs: empty source")

  local dst5 = {}
  local src5 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }
  local expected5 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }
  M.merge_digraphs(src5, dst5)
  assert_digraphs_tables_equal(expected5, dst5, "merge_digraphs: empty destination")

  local dst6 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }

  local src6 = {
    { digraph = 'SM', symbol = '☺', name = 'NEW FACE' },
    { digraph = '12', symbol = 'a', name = 'test' },
  }

  local expected6 = {
    { digraph = 'SM', symbol = '☺', name = 'NEW FACE' },
    { digraph = '12', symbol = 'a', name = 'test' },
  }

  M.merge_digraphs(src6, dst6)
  assert_digraphs_tables_equal(expected6, dst6, "merge_digraphs: Multiple changes")

  local dst7 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }

  local src7 = {
    { digraph = 'SM', symbol = '☺', name = nil },
  }

  local expected7 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' }
  }

  M.merge_digraphs(src7, dst7)
  assert_digraphs_tables_equal(expected7, dst7, "merge_digraphs: nil name value");

  local dst8 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }

  local src8 = {
    { digraph = nil, symbol = '☺', name = 'new name' },
  }

  local expected8 = {
    { digraph = 'SM', symbol = '☺', name = 'new name' },
  }

  M.merge_digraphs(src8, dst8)
  assert_digraphs_tables_equal(expected8, dst8, "merge_digraphs: nil digraph value")

  local dst9 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }

  local src9 = {
    { digraph = nil, symbol = '☺', name = nil },
  }

  local expected9 = {
    { digraph = 'SM', symbol = '☺', name = 'SMILING FACE' },
  }

  M.merge_digraphs(src9, dst9)
  assert_digraphs_tables_equal(expected9, dst9, "merge_digraphs: nil digraph and name value")
end

-- Do the tests
test_validate_digraphs()
test_merge_digraphs()

local exit_code = 0
if tests_failed then
  exit_code = 1
  print('\n')
end
vim.api.nvim_command('cq ' .. exit_code)
