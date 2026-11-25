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
