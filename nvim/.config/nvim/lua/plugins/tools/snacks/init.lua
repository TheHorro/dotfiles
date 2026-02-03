return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- Visual Styles & UI
    styles = {
      blame_lines = {
        width = 0.6,
        height = 0.6,
        border = "rounded",
        title = " Git Blame ",
        title_pos = "center",
        ft = "git",
      }
    },
    indent = {
      enabled = true,
      priority = 1,
      char = "│",
      -- only_scope = false,
      -- only_current = false,
      animate = { enabled = false },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "notify", "toggleterm", },
      },
      scope = {
        enabled = true,
        priority = 200,
        underline = true,
        hl = "SnacksIndentScope",
      },
    },
    input = {
      enabled = true,
      backdrop = true,
      position = "float",
      border = "rounded",
      title_pos = "center",
      expand = true,
    },
    notifier = {
      enabled = true,
      timeout = 4000,
      level = vim.log.levels.TRACE,
      style = "compact",
      top_down = true,
    },

    -- Picker & Explorer
    picker = require("plugins.tools.snacks.picker").picker,

    -- Essential Modules
    explorer = { enabled = true, replace_netrw = true, },
    bigfile = { enabled = true, size = 100 * 1024, },
    dashboard = {
      enabled = true,
      preset = require("plugins.tools.snacks.dashboard").preset,
      sections = require("plugins.tools.snacks.dashboard").sections,
    },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    lazygit = { enabled = true },
    -- notify = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    statuscolumn = { enabled = false },
    terminal = { enabled = true },
    words = { enabled = true },
    bufdelete = { enabled = true },

    image = require("plugins.tools.snacks.image").image,
  },
  config = function(_, opts)
    local indent_colors = {
      "#E06C75",
      "#E5E07B", 
      "#61AFEF", 
      "#D19A66",
      "#98C379", 
      "#C678DD", 
      "#56B6C2", 
      "#ABB2BF"
    }

    for i, color in ipairs(indent_colors) do
      vim.api.nvim_set_hl(0, "SnacksIndent" .. i, { fg = color, nocombine = true })
    end

    vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#C678DD", bold = true, nocombine = true })

    local snacks =  require("snacks")
    snacks.setup(opts)
    -- Use Snacks for the native vim UI input
    vim.ui.input = snacks.input

    local original_select = vim.ui.select
    vim.ui.select = function(items, select_opts, on_choice)
      select_opts = select_opts or {}

      -- If it's a confirmation/deletion, use the tiny "cursor" layout
      if select_opts.kind == "confirmation" or select_opts.kind == "file_deletion" then
        return snacks.picker.select(items, select_opts, function(item)
          on_choice(item)
        end, 
        {
          layout = {
            preset = "cursor",
            width = 0.2,
            height = 0.15,
          },
          main = { border = "rounded" },
          preview = false,
        })
      end

      -- Default: use the standard Snacks ui_select (dropdown style)
      return original_select(items, select_opts, on_choice)
    end

  end,
}
