-- blink.cmp is added in 'plugin/41_lsp.lua' (its capabilities are needed there).
Config.now_if_args(function()
  require('blink.cmp').setup({
    keymap = { preset = 'default' },
    completion = {
      ghost_text = { enabled = true },
      documentation = { auto_show = true },
    },
    snippets = { preset = 'mini_snippets' },
    sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    signature = { enabled = true },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  })
end)
