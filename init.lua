-- ┌────────────────────┐
-- │ Welcome to MiniMax │
-- └────────────────────┘
--
-- This is a config designed to mostly use MINI. It provides out of the box
-- a stable, polished, and feature rich Neovim experience. Its structure:
--
-- ├ init.lua          Initial (this) file executed during startup
-- ├ plugin/           Files automatically sourced during startup
-- ├── 10_options.lua  Built-in Neovim behavior
-- ├── 20_keymaps.lua  Custom mappings
-- ├── 30_mini.lua     MINI configuration
-- ├── 40_plugins.lua  Plugins outside of MINI
-- ├ snippets/         User defined snippets (has demo file)
-- ├ after/            Files to override behavior added by plugins
-- ├── ftplugin/       Files for filetype behavior (has demo file)
-- ├── lsp/            Language server configurations (has demo file)
-- ├── snippets/       Higher priority snippet files (has demo file)
--
-- Config files are meant to be read, preferably inside a Neovim instance running
-- this config and opened at its root. This will help you better understand your
-- setup. Start with this file. Any order is possible, prefer the one listed above.
-- Ways of navigating your config:
-- - `<Space>` + `e` + (one of) `iokmp` - edit 'init.lua' or 'plugin/' files.
-- - Inside config directory: `<Space>ff` (picker) or `<Space>ed` (explorer)
-- - Navigate existing buffers with `[b`, `]b`, or `<Space>fb`.
--
-- Config files are also meant to be customized. Initially it is a baseline of
-- a working config based on MINI. Modify it to make it yours. Some approaches:
-- - Modify already existing files in a way that keeps them consistent.
-- - Add new files in a way that keeps config consistent.
--   Usually inside 'plugin/' or 'after/'.
--
-- Documentation comments like this can be found throughout the config.
-- Common conventions:
--
-- - See `:h key-notation` for key notation used.
-- - `:h xxx` means "documentation of helptag xxx". Either type text directly
--   followed by Enter or type `<Space>fh` to open a helptag fuzzy picker.
-- - "Type `<Space>fh`" means "press <Space>, followed by f, followed by h".
--   Unless said otherwise, it assumes that Normal mode is current.
-- - "See 'path/to/file'" means see open file at described path and read it.
-- - `:SomeCommand ...` or `:lua ...` means execute mentioned command.

-- ┌────────────────┐
-- │ Plugin manager │
-- └────────────────┘
--
-- This config uses `vim.pack` - built-in plugin manager. Its main entry
-- point is a `vim.pack.add()` function, which acts like a "smarter `:packadd`":
-- load plugin after making sure it is installed from source. The state of
-- installed plugins is recorded in the lockfile named 'nvim-pack-lock.json'.
-- Example usage:
-- - `vim.pack.add({ ... })` - use inside config to add one or more plugins.
-- - `:lua vim.pack.update()` - update all plugins; execute `:write` to confirm.
-- - `:lua vim.pack.del({ ... })` - delete specific plugins.
--
-- See also:
-- - `:h vim.pack-examples` - how to use it
-- - `:h vim.pack-lockfile` - lockfile info
-- - `:h vim.pack-events` - available events and plugin hooks examples
-- - `:h vim.pack.update()` - more details about confirmation step

-- Define config table to be able to pass data between scripts
-- It is a global variable which can be use both as `_G.Config` and `Config`
_G.Config = {}

-- Define custom autocommand group and helper to create an autocommand.
-- Autocommands are Neovim's way to define actions that are executed on events
-- (like creating a buffer, setting an option, etc.).
--
-- See also:
-- - `:h autocommand`
-- - `:h nvim_create_augroup()`
-- - `:h nvim_create_autocmd()`
local gr = vim.api.nvim_create_augroup('custom-config', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

-- Define custom `vim.pack.add()` hook helper. Plugin data is passed as
-- argument to the callback. See `:h vim.pack-events`.
-- Example usage: see 'plugin/40_plugins.lua'.
-- If any plugin requires installation hooks, add them after this function
-- and before the first `vim.pack.add()` call.
Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end

-- User commands for `vim.pack`, modeled after 'mini.deps' ones. Use `!` to
-- skip confirmation. Plugin names are optional and complete with <Tab>.
-- - `:PackAdd user/repo` - add plugin to current session (install if needed).
-- - `:PackUpdate[!] [name ...]` - update plugins.
-- - `:PackUpdateOffline[!] [name ...]` - same, but without downloading.
-- - `:PackRestore[!] [name ...]` - revert plugins to lockfile revisions.
-- - `:PackClean[!]` - delete plugins not added to current session.
-- - `:PackDel[!] name ...` - delete plugins (`!` allows active ones).
-- - `:PackShowLog` - open update log.
local pack_names = function() return vim.tbl_map(function(p) return p.spec.name end, vim.pack.get(nil, { info = false })) end
local pack_complete = function(lead)
  return vim.tbl_filter(function(n) return vim.startswith(n, lead) end, pack_names())
end
local pack_cmd = function(name, impl, opts)
  -- Default: optional plugin names with completion, and `!` to force
  opts = opts or { nargs = '*', bang = true, complete = pack_complete }
  vim.api.nvim_create_user_command(name, impl, opts)
end
local fargs_or_nil = function(args) return #args.fargs > 0 and args.fargs or nil end

pack_cmd('PackAdd', function(args)
  local src = args.args:find('://') and args.args or ('https://github.com/' .. args.args)
  vim.pack.add({ src })
end, { nargs = 1 })
pack_cmd('PackUpdate', function(args)
  vim.pack.update(fargs_or_nil(args), { force = args.bang })
end)
pack_cmd('PackUpdateOffline', function(args)
  vim.pack.update(fargs_or_nil(args), { force = args.bang, offline = true })
end)
pack_cmd('PackRestore', function(args)
  vim.pack.update(fargs_or_nil(args), { force = args.bang, target = 'lockfile' })
end)
pack_cmd('PackClean', function(args)
  local inactive = vim.tbl_filter(function(p) return not p.active end, vim.pack.get(nil, { info = false }))
  local names = vim.tbl_map(function(p) return p.spec.name end, inactive)
  if #names == 0 then return vim.notify('vim.pack: nothing to clean') end
  local msg = 'Delete these plugins?\n' .. table.concat(names, '\n')
  if args.bang or vim.fn.confirm(msg, '&Yes\n&No', 2) == 1 then vim.pack.del(names) end
end, { bang = true })
pack_cmd('PackDel', function(args)
  vim.pack.del(args.fargs, { force = args.bang })
end, { nargs = '+', bang = true, complete = pack_complete })
pack_cmd('PackShowLog', function()
  vim.cmd.edit(vim.fn.stdpath('log') .. '/nvim-pack.log')
end, {})

-- 'mini.nvim' - all-in-one plugin powering most MiniMax features.
-- See 'plugin/30_mini.lua' for how it is used.
-- Load now to have 'mini.misc' available for custom loading helpers.
vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

-- Loading helpers used to organize config into fail-safe parts. Example usage:
-- - `now` - execute immediately. Use for what must be executed during startup.
--   Like colorscheme, statusline, tabline, dashboard, etc.
-- - `later` - execute a bit later. Use for things not needed during startup.
-- - `now_if_args` - use only if needed during startup when Neovim is started
--   like `nvim -- path/to/file`, but otherwise delaying is fine.
-- - Others are better used only if the above is not enough for good performance.
--   Use only if you are comfortable with adding complexity to your config:
--   - `on_event` - execute once on a first matched event. Like "delay until
--     first Insert mode enter": `on_event('InsertEnter', function() ... end)`.
--   - `on_filetype` - execute once on a first matched filetype. Like "delay
--     until first Lua file": `on_filetype('lua', function() ... end)`.
--
-- See also:
-- - `:h MiniMisc.safely()`
-- - 'plugin/30_mini.lua' and 'plugin/40_plugins.lua'
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

if vim.g.neovide then
  vim.o.guifont = "Maple Mono NL NF CN:h12"
  vim.g.neovide_cursor_animation_length = 0
end
