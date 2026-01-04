return {
  "barreiroleo/ltex_extra.nvim",
  ft = { "markdown", "tex" },
  opts = {
    -- The path where your dictionaries will be stored
    path = vim.fn.stdpath("config") .. "/ltex", 
    load_langs = { "de-DE" }, -- Add other languages you use here
    init_check = false,
    -- This plugin will automatically find and use ltex_plus if installed
  },
}
