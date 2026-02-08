

return {
  "nvim-lualine/lualine.nvim",
  event = "BufReadPost", -- Only load when an actual file is read
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local mode = {
      "mode",
      fmt = function(str)
        -- return ' '
        -- displays only the first character of the mode
        return " " .. str
      end,
    }

    local function vimtex_status()
      if vim.b.vimtex and vim.b.vimtex.compiler then
        local state = vim.b.vimtex.compiler.state
        local status_map = {
          [0] = "󱎘 Stopped", -- Compiler not running
          [1] = "󱐋 Running", -- Compiler active/continuous
          [2] = "󰚌 Failed",  -- Last compilation failed
        }
        return status_map[state] or ""
      end
      return ""
    end

    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "carbonfox",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
        disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } }
      },
      sections = {
        lualine_a = { mode },
        lualine_b = {
          {
            "branch",
            icon = "",
            colored = true,
          },
          {
            "diff",
            colored = true,
            diff_color = {
              added = { fg = "#45ff45" },
              removed = { fg = "#ff2b2b" },
            }
          },
          "diagnostics"
        },
        lualine_c = {
          {
            "filename",
            path = 1,
          },
        },
        lualine_x = {
          {
            function()
              if vim.bo.filetype == 'tex' and vim.b.vimtex and vim.b.vimtex.compiler then
                local status = vim.b.vimtex.compiler.status
                local ret = 'Vimtex: '
                if status == 2 then
                  return ret .. ' '
                elseif status == 1 then
                  return ret .. ' '
                elseif status == 0 then
                  return ret .. ' '
                end

              end
              return ''
            end,
          },
          -- "encoding",
          -- 'fileformat',
          "filetype",
        },
        lualine_y = {
          "progress",
          "filesize",
        },
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
