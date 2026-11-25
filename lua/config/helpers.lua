-- Helpers shared by config files, exposed through the global `Config` table.
-- Requires 'mini.nvim' to be added already (see 'init.lua').

-- Custom autocommand group and helper to create an autocommand.
-- See `:h nvim_create_augroup()`, `:h nvim_create_autocmd()`.
local gr = vim.api.nvim_create_augroup('custom-config', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

-- `vim.pack.add()` hook helper. Plugin data is passed as argument to the
-- callback. See `:h vim.pack-events`. Example: 'plugin/40_treesitter.lua'.
Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end

-- Loading helpers used to organize config into fail-safe parts:
-- - `now` - execute immediately (colorscheme, statusline, etc.).
-- - `later` - execute a bit later.
-- - `now_if_args` - `now` if Neovim started with file arguments, else `later`.
-- See `:h MiniMisc.safely()`.
local misc = require('mini.misc')
Config.now = function(f) misc.safely('now', f) end
Config.later = function(f) misc.safely('later', f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f) misc.safely('event:' .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely('filetype:' .. ft, f) end
Config.map = vim.keymap.set
Config.nmap = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end
