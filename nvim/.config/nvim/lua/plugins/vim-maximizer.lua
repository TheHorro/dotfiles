return {
	"szw/vim-maximizer",
	enabled = not vim.g.vscode,
	keys = {
		{ "<leader>sm", "<cmd>MaximizerToggle<CR>", desc = "Maximize/minimize a split" },
	},
}
