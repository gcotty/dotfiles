-- Automatically close and rename paired HTML-style tags.
-- Supports Vue, HTML, JSX/TSX, Svelte, XML, and other Treesitter filetypes.

vim.pack.add { 'https://github.com/windwp/nvim-ts-autotag' }
require('nvim-ts-autotag').setup {
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = false,
  },
}
