return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pylsp",
					"ltex",
					"ltex_plus",
					"clangd",
				},
				automatic_installation = true,
				handlers = nil,
			})
		end,
		opts = {
			auto_install = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.pylsp.setup({
				capabilities = capabilities,
			})
			lspconfig.ltex.setup({
				capabilities = capabilities,
			})
			lspconfig.ltex_plus.setup({
				capabilities = capabilities,
			})
			lspconfig.clangd.setup({
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--background-index",
					"-j=8",
				},
			})
			--      lspconfig.tsserver.setup({
			--        capabilities = capabilities
			--      })
			--      lspconfig.html.setup({
			--        capabilities = capabilities
			--      })
			--      lspconfig.lua_ls.setup({
			--        capabilities = capabilities
			--      })
		end,
	},
}
--clang-format
--python-lsp-server pylsp
--ltex-ls-plus ltex_plus
--ltex-ls ltex
--circom-lsp
--clangd
--lua-language-server
