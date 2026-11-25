-- MiniMax-based config. Structure:
--
-- ├ init.lua             Entry: global Config, vim.pack bootstrap, load order
-- ├ lua/config/          Modules required from init.lua
-- ├── helpers.lua        Config.now/later/new_autocmd/map helpers
-- ├── pack.lua           :Pack* commands for vim.pack
-- ├── languages.lua      LSP server and tree-sitter parser lists
-- ├ plugin/              Files automatically sourced during startup
-- ├── 10_options.lua     Built-in Neovim behavior
-- ├── 20_keymaps.lua     Custom mappings
-- ├── 30_mini.lua        MINI configuration
-- ├── 40_treesitter.lua  Tree-sitter
-- ├── 41_lsp.lua         LSP, Mason
-- ├── 42_format.lua      conform.nvim
-- ├── 43_ui.lua          Colorscheme, winbar
-- ├── 44_tools.lua       Git, projects, terminal, markdown, snippets
-- ├── 50_neovide.lua     GUI settings
-- ├ snippets/            User defined snippets
-- ├ after/               ftplugin/, lsp/, snippets/ overrides
--
-- Plugins are managed by `vim.pack` (lockfile: 'nvim-pack-lock.json').
-- See `:h vim.pack-examples`.

-- Global table to pass data between scripts: `Config`
_G.Config = {}

-- 'mini.nvim' is loaded now: 'lua/config/helpers.lua' needs 'mini.misc'.
vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

require('config.helpers')
require('config.pack')
