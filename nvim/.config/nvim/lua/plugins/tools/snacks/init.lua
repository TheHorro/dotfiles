return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
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
    bigfile = {
      enabled = true,
      notify = true,
      size = 100 * 1024, -- 100 KB
    },
    bufdelete = { enabled = true },
    dashboard = {
      enabled = true,
      -- Ensure these files exist or this will throw an error
      preset = require("plugins.tools.snacks.dashboard").preset,
      sections = require("plugins.tools.snacks.dashboard").sections,
    },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    image = {
      enabled = true,
      formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif", "mp4", "mov", "avi", "mkv", "webm", "pdf", "icns" },
      force_render = false,
      doc = {
        enabled = true,
        inline = false,
        float = true,
        max_width = 80,
        max_height = 40,
        render_patterns = {
          latex = {
            "\\\\includegraphics%s*%[[^%]]*%]%s*{([^}]*)}",
            "\\\\includegraphics%s*{([^}]*)}",
          },
        },
        conceal = function(lang, type)
          return type == "math"
        end,
      },
      icons = { math = "󰪚 ", chart = "󰄧 ", image = " " },
      math = {
        enabled = true,
        typst = {
          tpl = [[
            #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
            #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
            #set text(size: 12pt, fill: rgb("${color}"))
            ${header}
            ${content}]],
        },
      },
    },
    indent = {
      enabled = true,
      priority = 1,
      char = "│",
      only_scope = false,
      only_current = false,
      animate = { enabled = false },
      exclude = {
        filetypes = {
          "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "notify", "toggleterm",
        },
      },
      indent = {
        hl = {
          "SnacksIndent1", "SnacksIndent2", "SnacksIndent3", "SnacksIndent4",
          "SnacksIndent5", "SnacksIndent6", "SnacksIndent7", "SnacksIndent8",
        },
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
      backdrop = false,
      position = "float",
      border = "rounded",
      title_pos = "center",
      win = { style = 'input' },
      expand = true,
    },
    lazygit = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 4000,
      level = vim.log.levels.TRACE,
      style = 'compact',
      top_down = true,
    },
    notify = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    statuscolumn = { enabled = false },
    terminal = { enabled = true },
    win = { enabled = true },
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
  end,
}
