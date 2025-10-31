return {
	"lervag/vimtex",
	config = function()
		-- Basic vimtex settings
		vim.g.vimtex_view_method = "zathura" -- Your preferred PDF viewer
		vim.g.vimtex_compiler_method = "latexmk" -- Use latexmk for compiling
		vim.g.vimtex_complete_enabled = 1 -- Enable LaTeX completion
		vim.g.vimtex_fold_enabled = 1 -- Enable folding for LaTeX sections
		vim.opt.spell = true -- Enable spell-checking in LaTeX comments and text
	end,
}
