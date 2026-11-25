-- Tree-sitter: parsers and queries from 'nvim-treesitter'. See `:h treesitter`.
-- Troubleshooting: `:checkhealth vim.treesitter nvim-treesitter`.
-- Parsers need a C compiler; see MiniMax README "Requirements".
Config.now_if_args(function()
  -- Update parsers after the plugin is updated
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  vim.pack.add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  -- Languages to install and auto enable. Restart Neovim once after changing
  -- the list in 'lua/config/languages.lua' to install the parsers.
  local languages = require('config.languages').install_ts
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev)
    vim.treesitter.start(ev.buf)
    -- Use tree-sitter indent where no filetype indent script sets one
    if vim.bo[ev.buf].indentexpr == "" then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)
