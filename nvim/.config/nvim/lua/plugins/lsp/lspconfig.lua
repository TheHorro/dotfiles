return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },

	config = function()
		vim.diagnostic.config({
			virtual_text = false,
			signs = {
				active = true,
				values = {
					{ name = "DiagnosticSignError", text = "" },
					{ name = "DiagnosticSignWarn", text = "" },
					{ name = "DiagnosticSignInfo", text = "󰠠" },
					{ name = "DiagnosticSignHint", text = "" },
				},
			},
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		local on_attach = function(client, bufnr) end

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local ok, blink = pcall(require, "blink.cmp")
		if ok then
			capabilities = blink.get_lsp_capabilities(capabilities)
		end

		---------------------------------------------------------------------------
		-- specific Server configs
		---------------------------------------------------------------------------
		-- lua_ls
		-- installs by AUR: `yay -S lua-language-server` as Mason has version issues of libs bc of Arch
		vim.lsp.config(
			"lua_ls",
			vim.tbl_deep_extend("force", {
				autostart = false,
				cmd = { "lua-language-server" },
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = {
							globals = { "vim", "require", "pcall" },
							ignoredPatterns = { "Unused local" },
						},
						workspace = {
							checkThirdParty = false,
							library = {
								vim.fn.expand("$VIMRUNTIME/lua"),
								vim.fn.stdpath("config") .. "/lua",
							},
						},
					},
				},
			}, {
				on_attach = on_attach,
				capabilities = capabilities,
			})
		)

		-- texlab
		vim.lsp.config("texlab", {
			autostart = false,
			cmd = { "texlab" },
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				texlab = {
					build = { onSave = true },
					chktex = { onEdit = false, onOpenAndSave = false },
					diagnostics = {
						ignoredPatterns = { "Unused label" },
					},
					diagnosticsDelay = 300,
				},
			},
		})

		-- LTeX
		vim.lsp.config("ltex_plus", {
			autostart = false,
			cmd = { "ltex-ls-plus" },
			filetypes = { "bib", "gitcommit", "org", "plaintex", "rst", "rnoweb", "tex", "pandoc", "quarto", "rmd" },
			root_dir = vim.fs.root(0, { ".git", ".ltex", "main.tex" }),
			capabilities = capabilities,
			settings = {
				ltex = {
					language = "de-DE",
					enabled = { "latex", "tex", "bib" },
				},
			},
			-- on_init = function(client)
			-- 	vim.schedule(function()
			-- 		local ltex_ok, ltex_extra = pcall(require, "ltex_extra")
			-- 		if ltex_ok then
			-- 			ltex_extra.setup({
			-- 				load_langs = { "de-DE" },
			-- 				path = vim.fn.getcwd() .. "/.ltex", -- Absolute path ensures it finds it
			-- 				server_name = "ltex_plus",
			-- 			})
			-- 		end
			-- 	end)
			-- end,
			-- on_attach = function(client, bufnr)
			-- 	local ltex_ok, ltex_extra = pcall(require, "ltex_extra")
			-- 	if ltex_ok then
			-- 		ltex_extra.setup({
			-- 			load_langs = { "de-DE" },
			-- 			path = vim.fn.getcwd() .. "/.ltex",
			-- 		})
			-- 	end
			-- end,
		})

		vim.lsp.config("pyright", {
			autostart = false,
			cmd = { "pyright-langserver", "--stdio" },
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				python = {
					-- Conda ml-Umgebung fix eingetragen
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						typeCheckingMode = "basic",
					},
				},
			},
		})

		-- ruff (Linter + Formatter, ersetzt flake8/black/isort)
		-- installieren via: yay -S python-ruff (oder: pip install ruff in ml-env)
		vim.lsp.config("ruff", {
			autostart = false,
			cmd = { "ruff", "server" },
			on_attach = function(client, bufnr)
				-- Ruff übernimmt Formatting, Pyright nur Type-Checking
				-- Hover-Infos kommen von Pyright, nicht Ruff
				client.server_capabilities.hoverProvider = false
				on_attach(client, bufnr)
			end,
			capabilities = capabilities,
			init_options = {
				settings = {
					lineLength = 120,
					lint = {
						select = { "E", "F", "I", "UP" }, -- pycodestyle, pyflakes, isort, pyupgrade
					},
				},
			},
		})

		vim.lsp.config("clangd", {
			cmd = { "clangd" },
			filetypes = { "c", "cpp" },
			root_markers = {
				".clangd",
				".clang-tidy",
				".clang-format",
				"compile_commands.json",
				"compile_flags.txt",
				".git",
			},
			on_attach = on_attach,
			capabilities = capabilities,
		})

		vim.lsp.config("cssls", {
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore", -- silences @define-color errors
					},
					customData = {
						vim.fn.expand(os.getenv("HOME") .. "/.config/nvim/custom-data/css.json"),
					},
				},
			},
		})

		vim.lsp.enable({ "lua_ls", "pyright", "ruff", "texlab", "ltex_plus", "clangd", "cssls" })

		vim.api.nvim_create_autocmd({ "LspAttach" }, {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					return
				end

				if client.name == "stylua" then
					client:stop()
				elseif client.name == "ltex_plus" then
					local ltex_ok, ltex_extra = pcall(require, "ltex_extra")
					if not ltex_ok then
						return
					end
					ltex_extra.setup({
						loac_langs = { "de-DE", "en-US" },
						path = vim.fn.getcwd() .. "/.ltex",
					})
				end
			end,
		})
	end,
}
