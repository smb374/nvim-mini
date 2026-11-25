-- blink.cmp is added in 'plugin/41_lsp.lua' (its capabilities are needed there).
Config.now_if_args(function()
  require('blink.cmp').setup({
    keymap = {
      preset = 'default',
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
    },
    completion = {
      list = { selection = { preselect = false } },
      ghost_text = { enabled = true },
      documentation = { auto_show = true },
      menu = {
        draw = {
          components = {
            kind_icon = {
              text = function(ctx) return (require('mini.icons').get('lsp', ctx.kind)) end,
              highlight = function(ctx)
                local _, hl = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            },
            kind = {
              highlight = function(ctx)
                local _, hl = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            },
          },
        },
      },
    },
    snippets = { preset = 'mini_snippets' },
    sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    signature = { enabled = true },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  })
end)
