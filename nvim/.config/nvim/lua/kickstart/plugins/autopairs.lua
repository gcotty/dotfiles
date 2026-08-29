-- autopairs
-- https://github.com/windwp/nvim-autopairs

vim.pack.add { 'https://github.com/windwp/nvim-autopairs' }

local M = {}
local autopairs = require 'nvim-autopairs'
autopairs.setup {}

-- SQL indent queries sometimes leave the temporary empty body of the first CTE
-- at column zero, while correctly indenting subsequent CTEs. Supply one level
-- only when the live indenter did not provide one itself.
function M.indent_empty_sql_pair()
  local cursor = vim.api.nvim_win_get_cursor(0)
  if vim.bo.filetype ~= 'sql' or cursor[2] ~= 0 or vim.api.nvim_get_current_line() ~= '' then return end

  local spaces = string.rep(' ', vim.bo.shiftwidth)
  vim.api.nvim_set_current_line(spaces)
  vim.api.nvim_win_set_cursor(0, { cursor[1], #spaces })
end

autopairs.get_rule('('):replace_map_cr(function(opts)
  local mapping = '<C-g>u<CR><Cmd>normal! ====<CR><Up><End><CR>'
  if vim.bo[opts.bufnr].filetype == 'sql' then
    mapping = mapping .. "<Cmd>lua require('kickstart.plugins.autopairs').indent_empty_sql_pair()<CR>"
  end
  return mapping
end)

return M
