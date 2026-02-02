local M = {}

M.picker = {
  enabled = true,
  ui_select = true, 
  win = {
    input = {
      keys = {
        ["<C-j>"] = { "list_down", mode = { "i", "n" } },
        ["<C-k>"] = { "list_up", mode = { "i", "n" } },
        ["<Esc>"] = { "close", mode = { "i", "n" } },
        ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
        ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
      },
    },
    list = {
      keys = {
        ["<Tab>"] = "select_and_next",
        ["<S-Tab>"] = "select_and_prev",
        ["K"] = "list_top",
        ["J"] = "list_bottom",
      },
    },
  },
  sources = {
    explorer = {
      auto_close = false,
      hidden = true,
      ignored = false,
      layout = { layout = { position = "left", width = 35, title = "{title} {tree}", } },
      icons = {
        git = {
          added     = "✚", modified  = "󰷈", deleted   = "✖",
          renamed   = "󰁕", untracked = "", ignored   = "",
        },
      },
      win = {
        list = {
          keys = {
            ["l"] = "confirm",
            ["h"] = "explorer_up",
            ["a"] = "explorer_add",
            ["d"] = "explorer_del",
            ["r"] = "explorer_rename",
            ["y"] = "copy_to_clipboard",
            ["v"] = "edit_vsplit",
            ["i"] = "focus_input",
            ["/"] = "focus_input",
            ["H"] = "toggle_hidden",
            ["<Esc>"] = { "focus_list", mode = { "n", "i" } },
          },
        },
      },
    },
    undo = {
      win = {
        input = {
          keys = {
            ["<C-a>"] = { "yank_additions", mode = { "n", "i" } },
            ["<C-d>"] = { "yank_deletions", mode = { "n", "i" } },
            ["<C-u>"] = { "restore", mode = { "n", "i" } },
          },
        },
      },
    },
  },
}

return M
