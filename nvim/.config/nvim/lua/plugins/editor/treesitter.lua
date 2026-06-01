return {
	{
		"neovim-treesitter/nvim-treesitter",
		dependencies = { "neovim-treesitter/treesitter-parser-registry" },
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			local parsers = {
				"bash",
				"css",
				"c",
				"cpp",
				"editorconfig",
				"git_config",
				"git_rebase",
				"gitattributes",
				"gitcommit",
				"gitignore",
				"json",
				"lua",
				"latex",
				"markdown",
				"markdown_inline",
				"python",
				"rust",
				"toml",
				"typst",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
				"zsh",
			}

			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyDone",
				once = true,
				callback = function()
					ts.install(parsers)
				end,
			})
			ts.highlight = true

			local ft_patterns = {}
			for _, parser in ipairs(parsers) do
				for _, ft in ipairs(vim.treesitter.language.get_filetypes(parser)) do
					table.insert(ft_patterns, ft)
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = ft_patterns,
				callback = function()
					vim.treesitter.start() -- highlighting
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- folds
					vim.wo.foldmethod = "expr"
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- indentation
				end,
			})
		end,
	},
	{
		"vim-python/python-syntax",
		config = function()
			vim.g.python_highlight_all = 1
		end,
	},

	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		opts = {
			enable_autocmd = false,
		},
	},

	{
		"windwp/nvim-ts-autotag",
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true,
			},
		},
	},
}
