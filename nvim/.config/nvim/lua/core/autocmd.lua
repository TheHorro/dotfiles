vim.api.nvim_create_autocmd("FileType", {
	pattern = "hyprlang",
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 2

		vim.opt_local.softtabstop = 2
		-- Disable Treesitter-based indentexpr for this filetype
		vim.opt_local.indentexpr = ""
		vim.opt_local.autoindent = true
		vim.opt_local.smartindent = true
	end,
})
