Config.now_if_args(function()
  vim.pack.add({
    'https://github.com/folke/lazydev.nvim',
    'https://github.com/williamboman/mason.nvim',
    'https://github.com/williamboman/mason-lspconfig.nvim',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/MysticalDevil/inlay-hints.nvim',
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
  })
  local languages = require('config.languages')

  require("lazydev").setup({
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  })

  local capabilities = require('blink.cmp').get_lsp_capabilities({
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  })

  vim.lsp.config("*", {
    capabilities = capabilities,
    root_markers = { ".git" },
  })
  require("mason").setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })
  require("mason-lspconfig").setup({
    ensure_installed = languages.install_server,
    automatic_enable = true,
  })

  for _, server in ipairs(languages.external_server) do
    vim.lsp.config(server, {
      capabilities = capabilities,
    })
    vim.lsp.enable(server)
  end

  require("inlay-hints").setup()
end)
