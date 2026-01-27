-----------------------------------------------------------
-- Git Signs Plugin Configuration
--
-- This module configures gitsigns.nvim to show git status indicators
-- in the sign column. Features:
-- - Minimalistic vertical lines for added/changed/deleted lines
-- - Consistent sign appearance across different change types
-- - Clear distinction for different types of changes
-- - Integration with git commands via keybindings
-----------------------------------------------------------

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      -- Using minimal vertical bar for most changes
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "▎" },
      topdelete = { text = "▎" },
      changedelete = { text = "▎" },
    },

    -- Core settings
    signcolumn = true, -- Show signs in the sign column
    numhl = false,     -- Don't highlight line numbers
    linehl = false,    -- Don't highlight the whole line
    word_diff = false, -- Don't show word diff inline

    -- Git monitoring
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,

    -- Blame functionality
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
    },

    -- Performance settings
    sign_priority = 6,
    update_debounce = 100,
    max_file_length = 40000,

    -- Preview window config
    preview_config = {
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
  },
  config = function(_, opts) 
    require("gitsigns").setup(opts)
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        -- Reset sign column background
        vim.api.nvim_set_hl(0, "SignColumn", { link = "Normal" })

        local add_color    = "#00ff00" -- Green
        local change_color = "#4fa6ed" -- light blue
        local delete_color = "#ff0000" -- Red

        -- Apply colors to GitSigns
        vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = add_color, bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSignsChange", { fg = change_color, bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = delete_color, bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = delete_color, bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = change_color, bg = "NONE" })

        -- Store globally if needed for other plugins
        _G.GitColors = {
          add = add_color,
          change = change_color,
          delete = delete_color,
        }
      end,
      group = vim.api.nvim_create_augroup("GitSignsHighlight", { clear = true }),
    })

    -- Trigger the autocmd once immediately so highlights apply on first load
    vim.api.nvim_exec_autocmds("ColorScheme", {})
  end
}
