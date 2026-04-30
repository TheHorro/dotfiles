-- plugins/venv.lua
return {
	"linux-cultist/venv-selector.nvim",
	branch = "regexp", -- neuere Version mit Mamba-Support
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("venv-selector").setup({
			settings = {
				search = {
					-- Pfad zu deinen Mamba-Umgebungen anpassen:
					anaconda_envs = {
						command = "fd bin/python$ ~/miniforge3/envs --full-path --color never -E /proc",
					},
					anaconda_base = {
						command = "fd /python$ ~/miniforge3/bin --full-path --color never -E /proc",
					},
				},
			},
		})
	end,
	keys = {
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Python Env wählen" },
		{ "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Letzte Env laden" },
	},
}
