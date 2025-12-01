return {
  "nvim-lualine/lualine.nvim",
  event = "BufReadPost", -- Only load when an actual file is read
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
		local colors = {
			color0 = "#092236",
			color1 = "#ff5874",
			color2 = "#c3ccdc",
			color3 = "#1c1e26",
			color6 = "#a1aab8",
			color7 = "#828697",
			color8 = "#ae81ff",
		}
		local my_lualine_theme = {
			replace = {
				a = { fg = colors.color0, bg = colors.color1, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
			inactive = {
				a = { fg = colors.color6, bg = colors.color3, gui = "bold" },
				b = { fg = colors.color6, bg = colors.color3 },
				c = { fg = colors.color6, bg = colors.color3 },
			},
			normal = {
				a = { fg = colors.color0, bg = colors.color7, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
				c = { fg = colors.color2, bg = colors.color3 },
			},
			visual = {
				a = { fg = colors.color0, bg = colors.color8, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
			insert = {
				a = { fg = colors.color0, bg = colors.color2, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
		}

		local mode = {
			"mode",
			fmt = function(str)
				-- return ' '
				-- displays only the first character of the mode
				return " " .. str
			end,
		}
    -- Initial minimal setup
    require("lualine").setup({
      options = {
        icons_enabled = false, -- Disable icons initially for faster load
        -- theme = "gruvbox",
        theme = my_lualine_theme,
        component_separators = "",
        section_separators = "",
        refresh = {
          statusline = 2000, -- Reduce refresh frequency
          tabline = 2000,
          winbar = 2000,
        },
      },
      sections = {
        lualine_a = { mode },
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = {
          { "encoding" },
          { "fileformat" },
          { "filetype" },
          -- "filetype" 
        },
        lualine_y = {},
        lualine_z = { "location" },
      },
    })

    require("lualine").setup({
      options = {
        icons_enabled = true,
        -- theme = "gruvbox",
        theme = my_lualine_theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          "filename",
        },
        lualine_x = {
          -- { require('mcphub.extensions.lualine') },
          -- 'encoding',
          -- 'fileformat',
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    })
  end,
}
