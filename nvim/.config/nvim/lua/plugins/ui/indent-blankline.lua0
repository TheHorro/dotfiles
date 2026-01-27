local highlight = {
  "RainbowRed",
  "RainbowOrange",
  "RainbowYellow",
  "RainbowGreen",
  "RainbowBlue",
  "RainbowCyan",
  "RainbowViolet",
}

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    indent = {
      char = "│",
      smart_indent_cap = true,
      highlight = highlight,
    },
    scope = {
      enabled = true, -- Highlights the current scope/block
      -- show_start = false,
      -- show_end = false,
      highlight = { "IndentScope" },
    },
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "lazy",
        "mason",
      },
    },
  },
  config = function(_, opts)

    local hooks = require "ibl.hooks"
    -- create the highlight groups in the highlight setup hook, so they are reset
    -- every time the colorscheme changes
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5E07B" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      vim.api.nvim_set_hl(0, "IndentScope", { fg = "#EB34CC" })
    end)
    require("ibl").setup(opts)
  end,
}
