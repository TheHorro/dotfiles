return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>if",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Format buffer",
		},
	},
	opts = {
		-- ─── Formatters per filetype ──────────────────────────────────────
		formatters_by_ft = {
			-- Web
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			svelte = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			scss = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			jsonc = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			graphql = { "prettierd", "prettier", stop_after_first = true },

			-- Systems / scripting
			lua = { "stylua" },
			python = { "isort", "black" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
			rust = { "rustfmt" },
			go = { "gofumpt", "goimports" },
			c = { "clang_format" },
			cpp = { "clang_format" },

			-- Hyprland — no standalone formatter, fall back to hyprls LSP
			hyprlang = { "hypr_indent" },

			-- Catch-all: attempt LSP formatting for unknown filetypes
			["_"] = { "trim_whitespace" },
		},

		-- ─── Format on save ───────────────────────────────────────────────
		format_on_save = function(bufnr)
			-- Disable auto-format globally or per-buffer with these flags:
			--   vim.g.disable_autoformat = true
			--   vim.b[bufnr].disable_autoformat = true
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			-- For hyprlang (and any ft with no formatter), fall back to LSP
			return {
				timeout_ms = 500,
				lsp_format = "fallback",
			}
		end,

		-- ─── Formatter options ────────────────────────────────────────────
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2", "-ci" }, -- 2-space indent, case-indent
			},
			black = {
				prepend_args = { "--line-length", "88" },
			},
			isort = {
				prepend_args = { "--profile", "black" },
			},
			hypr_indent = {
				format = function(_, _, lines, callback)
					local result = {}
					local indent = 0
					for _, line in ipairs(lines) do
						local stripped = line:match("^%s*(.-)%s*$") -- trim whitespace
						if stripped:match("^}") then
							indent = math.max(0, indent - 1)
						end
						if stripped ~= "" then
							table.insert(result, string.rep("  ", indent) .. stripped)
						else
							table.insert(result, "")
						end
						if stripped:match("{%s*$") then
							indent = indent + 1
						end
					end
					callback(nil, result)
				end,
			},
		},
	},

	-- ─── Toggle autoformat commands ─────────────────────────────────────
	config = function(_, opts)
		require("conform").setup(opts)

		-- :FormatDisable / :FormatEnable to toggle globally
		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! → buffer-local only
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, { desc = "Disable autoformat on save", bang = true })

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, { desc = "Enable autoformat on save" })

		-- Use conform for the `gq` motion
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
