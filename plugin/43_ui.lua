Config.now(function()
  vim.pack.add({
    'https://github.com/SmiteshP/nvim-navic',
    { src = 'https://github.com/utilyre/barbecue.nvim', name = 'barbecue' },
    { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  })
  require("catppuccin").setup({
    term_colors = true,
    integrations = {
      aerial = true,
      alpha = true,
      cmp = true,
      dashboard = true,
      flash = true,
      gitsigns = true,
      headlines = true,
      illuminate = true,
      indent_blankline = { enabled = true },
      leap = true,
      lsp_trouble = true,
      mason = true,
      markdown = true,
      mini = {
        enabled = true,
      },
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      navic = { enabled = true, custom_bg = "lualine" },
      neotest = true,
      neotree = true,
      noice = true,
      notify = true,
      semantic_tokens = true,
      telescope = true,
      treesitter = true,
      treesitter_context = true,
      which_key = true,
    },
  })
  vim.cmd.colorscheme("catppuccin")

  require("barbecue").setup()
end)
