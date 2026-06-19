-- Helper to detect specific LaTeX contexts (citations, refs, etc.)
local function is_latex_special_context()
	if vim.bo.filetype ~= "tex" then
		return false
	end
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local before = line:sub(1, col)

	-- Patterns for references and citations
	local patterns = {
		"\\cite[%w]*{[^}]*$",
		"\\[Cc]ref{[^}]*$",
		"\\ref{[^}]*$",
		"\\eqref{[^}]*$",
		"\\autoref{[^}]*$",
		"\\citet?[%w]*{[^}]*$",
	}
	for _, p in ipairs(patterns) do
		if before:match(p) then
			return true
		end
	end
	return false
end

return {
	{
		"saghen/blink.compat",
		version = "*",
		lazy = true,
		opts = { impersonate_nvim_cmp = true },
	},
	{
		"saghen/blink.cmp",
		version = "*", -- Use latest stable
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"saghen/blink.compat",
			"micangl/cmp-vimtex",
			-- "jdrupal-dev/css-vars.nvim",
			{ "L3MON4D3/LuaSnip", version = "v2.*" },
		},
		opts = {
			enabled = function()
				local filetype = vim.bo[0].filetype
				-- Disable for Telescope/picker buffers
				if filetype == "TelescopePrompt" or filetype == "minifiles" or filetype == "snacks_picker_input" then
					return false
				end
				return true
			end,
			snippets = { preset = "luasnip" },
			keymap = {
				preset = "default",
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "snippet_forward", "select_and_accept", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
			},

			appearance = {
				-- Only define what you want to change; others fall back to defaults
				kind_icons = {
					Text = "󰦨",
					Method = "󰆧",
					Function = "󰊕",
					Field = "󰇽",
					Variable = "󰂡",
					Class = "󰠱",
					Property = "󰜢",
					Value = "󰎠",
					Keyword = "󰌋",
					Color = "󰏘",
					File = "󰈙",
					Folder = "󰉋",
					Constant = "󰀫",
					Operator = "󰘧",
					TypeParameter = "󰅲",
				},
			},
			cmdline = {
				enabled = true,
				sources = { "cmdline" }, -- uses blink's built-in cmdline source
				keymap = {
					preset = "cmdline", -- uses arrow keys / tab for cmdline
				},
				completion = {
					menu = {
						auto_show = true,
					},
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					tex = { "snippets", "vimtex", "lsp", "path", "buffer" },
					-- css = { "lsp", "path", "snippets", "buffer", "css_vars" },
				},
				providers = {
					-- Use blink.compat to bring in the specialized vimtex source
					vimtex = {
						name = "vimtex",
						module = "blink.compat.source",
						score_offset = 100,
					},
					lsp = {
						enabled = function()
							return not is_latex_special_context()
						end,
					},
					path = {
						enabled = function()
							return not is_latex_special_context()
						end,
					},
					buffer = {
						enabled = function()
							return not is_latex_special_context()
						end,
						max_items = 8,
						min_keyword_length = 2,
						opts = {
							max_async_buffer_size = 500000,
							max_total_buffer_size = 1000000,
							use_cache = true,
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
							end,
						},
					},
					-- css_vars = {
					-- 	name = "css-vars",
					-- 	module = "css-vars.blink", -- ← css-vars has a native blink module
					-- 	opts = {
					-- 		search_extensions = { ".css" },
					-- 	},
					-- },
				},
			},

			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
						blocked_filetypes = { "tex", "latex", "markdown" },
					},
				},
				menu = {
					draw = {
						columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = { enabled = false },
			},
		},
	},
}
