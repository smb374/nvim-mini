local add = vim.pack.add
local later = Config.later

later(function() add({ 'https://github.com/rafamadriz/friendly-snippets' }) end)

later(function()
  add({
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/sindrets/diffview.nvim',
    'https://github.com/NeogitOrg/neogit',
  })

  require("neogit").setup({})
  Config.nmap("<leader>gg", "<cmd>Neogit<cr>", "Open Neogit")
end)

later(function()
  add({ 'https://github.com/ahmedkhalf/project.nvim' })

  require("project_nvim").setup({
    manual_mode = false,
    detection_methods = { "lsp", "pattern" },
    patterns = {
      ".git",
      "_darcs",
      ".hg",
      ".bzr",
      ".svn",
      "Makefile",
      "package.json",
      "mix.lock"
    },
    ignore_lsp = {},
    exclude_dirs = {},
    show_hidden = false,
    silent_chdir = true,
    scope_chdir = "global",
    datapath = vim.fn.stdpath("data"),
  })
  require("project_nvim.utils.history").read_projects_from_history()

  Config.nmap("<leader>fp", function()
    local history = require("project_nvim.utils.history")
    local pick = require("mini.pick")
    local function choose_action(item)
      if not vim.fn.isdirectory(item) then
        return
      end
      pick.builtin.files({}, {
        source = {
          cwd = item,
        },
      })
    end
    pick.start({
      source = {
        items = history.get_recent_projects(),
        choose = choose_action,
        name = "Projects"
      }
    })
  end, "Project")
end)

later(function()
  add({
    'https://github.com/nvzone/volt',
    'https://github.com/nvzone/floaterm',
  })

  Config.nmap("<C-_>", "<cmd>FloatermToggle<cr>", "Open floating terminal")
  Config.nmap("<C-/>", "<cmd>FloatermToggle<cr>", "Open floating terminal")
end)

later(function()
  add({ 'https://github.com/MeanderingProgrammer/render-markdown.nvim' })
  require("render-markdown").setup({})
  Config.nmap("<leader>pt", "<cmd>RenderMarkdown buf_toggle<cr>", "Toggle markdown render")
end)
