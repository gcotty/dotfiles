local M = {}
local initialized = false

local function set_highlight()
  vim.api.nvim_set_hl(0, 'NvimTreeBreadcrumb', { fg = '#1abc9c', ctermfg = 6, bold = true })
end

-- Keep nvim-tree's private rendering API behind this adapter. In particular,
-- its mapping accounts for filters and directories combined onto one row.
local function rendered_tree()
  local core = require 'nvim-tree.core'
  local explorer = core.get_explorer()
  if not explorer then return nil end
  return { root = explorer, rows = explorer:get_nodes_by_line(core.get_nodes_starting_line()) }
end

local function root_name(root)
  return vim.fs.basename(root.absolute_path) or root.name or '/'
end

local function context(tree, row)
  local node = tree.rows[row]
  if not node then return root_name(tree.root) end
  -- Directory nodes (including directory symlinks) have children storage.
  -- Include the selected folder itself, or the parent of a selected file.
  -- Combined a/b/c rows map to c, retaining the complete grouped path.
  if not node.nodes then node = node.parent end
  local parts = {}
  while node and node ~= tree.root do
    table.insert(parts, 1, node.name)
    node = node.parent
  end
  table.insert(parts, 1, root_name(tree.root))
  return table.concat(parts, '/')
end

local function shorten(path, width)
  if vim.fn.strdisplaywidth(path) <= width then return path end
  local parts = vim.split(path, '/', { plain = true, trimempty = true })
  while #parts > 1 do
    table.remove(parts, 1)
    local candidate = '…/' .. table.concat(parts, '/')
    if vim.fn.strdisplaywidth(candidate) <= width then return candidate end
  end
  local tail = parts[1] or ''
  while tail ~= '' and vim.fn.strdisplaywidth('…/' .. tail) > width do
    tail = vim.fn.strcharpart(tail, 1)
  end
  return width >= 2 and '…/' .. tail or (width == 1 and '…' or '')
end

function M.setup()
  if initialized then return end
  initialized = true
  local api = require 'nvim-tree.api'
  local cache, roots, pending = {}, {}, false

  local function update()
    pending = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if api.tree.is_tree_buf(buf) then
        local tree = cache[buf]
        if not tree then
          local ok, result = pcall(rendered_tree)
          tree = ok and result or nil
          if tree then
            cache[buf] = tree
            roots[buf] = root_name(tree.root)
          end
        end
        local path = ''
        if tree then
          path = context(tree, vim.api.nvim_win_get_cursor(win)[1])
        else
          local ok, root = pcall(api.tree.get_nodes)
          if ok and root and root.absolute_path then roots[buf] = root_name(root) end
          path = roots[buf] or ''
        end
        -- Literal option text, not an expression: filenames must not become
        -- statusline directives, and control characters must stay on one line.
        path = path:gsub('%c', ' ')
        local label = shorten(path, math.max(0, vim.api.nvim_win_get_width(win) - 2))
        local value = '%#NvimTreeBreadcrumb# ' .. label:gsub('%%', '%%%%') .. ' %*'
        if vim.wo[win].winbar ~= value then vim.wo[win].winbar = value end
      end
    end
  end

  local function schedule()
    if pending then return end
    pending = true
    vim.schedule(update)
  end

  local group = vim.api.nvim_create_augroup('nvim-tree-breadcrumb', { clear = true })
  set_highlight()
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = set_highlight })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'WinScrolled', 'WinResized', 'BufWinEnter', 'WinEnter', 'TabEnter' }, {
    group = group,
    callback = schedule,
  })
  vim.api.nvim_create_autocmd({ 'WinClosed', 'BufWipeout' }, {
    group = group,
    callback = function(ev)
      cache = {}
      if ev.event == 'BufWipeout' then roots[ev.buf] = nil end
      schedule()
    end,
  })
  api.events.subscribe(api.events.Event.TreeRendered, function()
    cache = {}
    schedule()
  end)
  api.events.subscribe(api.events.Event.TreeOpen, schedule)
  schedule()
end

return M
