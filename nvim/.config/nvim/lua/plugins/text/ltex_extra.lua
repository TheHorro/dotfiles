return {
  "barreiroleo/ltex_extra.nvim",
  ft = { "markdown", "tex" },
  opts = {
    -- The path where your dictionaries will be stored
    load_langs = { "de-DE" }, -- Add other languages you use here
    path = vim.fn.getcwd() .. "/.ltex",
    -- init_check = false,
    -- This plugin will automatically find and use ltex_plus if installed
  },
}
