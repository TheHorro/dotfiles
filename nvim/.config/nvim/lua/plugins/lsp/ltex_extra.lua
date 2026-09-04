return {
	"barreiroleo/ltex_extra.nvim",
	ft = { "tex" },
	opts = function()
		local root = vim.fs.root(0, { ".git", ".ltex", "main.tex" }) or vim.fn.getcwd()
		return {
			-- The path where your dictionaries will be stored
			load_langs = { "de-DE", "en-US" }, -- Add other languages you use here
			path = root .. "/.ltex",
			-- init_check = false,
			-- This plugin will automatically find and use ltex_plus if installed
		}
	end,
}
