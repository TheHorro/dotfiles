return {
	-- HACK: docs @ https://github.com/folke/snacks.nvim/blob/main/docs
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		-- NOTE: Options
		opts = {
			styles = {
				input = {
					keys = {
						n_esc = { "<C-c>", { "cmp_close", "cancel" }, mode = "n", expr = true },
						i_esc = { "<C-c>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
					},
				},
			},
			-- Snacks Modules
			input = {
				enabled = true,
			},
			quickfile = {
				enabled = true,
				exclude = { "latex" },
			},
			-- HACK: read picker docs @ https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
			picker = {
				enabled = true,
				matchers = {
					frecency = true,
					cwd_bonus = false,
				},
				formatters = {
					file = {
						filename_first = false,
						filename_only = false,
						icon_width = 2,
					},
				},
				layout = {
					-- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
					-- override picker layout in keymaps function as a param below
					preset = "telescope", -- defaults to this layout unless overidden
					cycle = false,
				},
				layouts = {
					select = {
						preview = false,
						layout = {
							backdrop = false,
							width = 0.6,
							min_width = 80,
							height = 0.4,
							min_height = 10,
							box = "vertical",
							border = "rounded",
							title = "{title}",
							title_pos = "center",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
							{ win = "preview", title = "{preview}", width = 0.6, height = 0.4, border = "top" },
						},
					},
					telescope = {
						reverse = true, -- set to false for search bar to be on top
						layout = {
							box = "horizontal",
							backdrop = false,
							width = 0.8,
							height = 0.9,
							border = "none",
							{
								box = "vertical",
								{ win = "list", title = " Results ", title_pos = "center", border = "rounded" },
								{
									win = "input",
									height = 1,
									border = "rounded",
									title = "{title} {live} {flags}",
									title_pos = "center",
								},
							},
							{
								win = "preview",
								title = "{preview:Preview}",
								width = 0.50,
								border = "rounded",
								title_pos = "center",
							},
						},
					},
					ivy = {
						layout = {
							box = "vertical",
							backdrop = false,
							width = 0,
							height = 0.4,
							position = "bottom",
							border = "top",
							title = " {title} {live} {flags}",
							title_pos = "left",
							{ win = "input", height = 1, border = "bottom" },
							{
								box = "horizontal",
								{ win = "list", border = "none" },
								{ win = "preview", title = "{preview}", width = 0.5, border = "left" },
							},
						},
					},
				},
			},
			image = {
				enabled = true,
				doc = {
					float = true, -- show image on cursor hover
					inline = false, -- show image inline
					max_width = 50,
					max_height = 30,
					wo = {
						wrap = false,
					},
				},
				convert = {
					notify = true,
					command = "magick",
				},
				img_dirs = {
					"img",
					"images",
					"assets",
					"static",
					"public",
					"media",
					"attachments",
					"Archives/All-Vault-Images/",
					"~/Library",
					"~/Downloads",
				},
			},
			dashboard = {
				enabled = true,
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
					-- {
					-- section = "terminal",
					-- cmd = "ascii-image-converter ~/Desktop/Others/profiles.JPG -C -c",
					-- random = 15,
					-- pane = 2,
					-- indent = 15,
					-- height = 20,
					-- },
				},
			},
		},
		-- NOTE: Keymaps
		keys = {
			{
				"<leader>lg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>gl",
				function()
					require("snacks").lazygit.log()
				end,
				desc = "Lazygit Logs",
			},
			{
				"<leader>rN",
				function()
					require("snacks").rename.rename_file()
				end,
				desc = "Fast Rename Current File",
			},
			{
				"<leader>dB",
				function()
					require("snacks").bufdelete()
				end,
				desc = "Delete or Close Buffer  (Confirm)",
			},

			-- Snacks Picker
			{
				"<leader>pf",
				function()
					require("snacks").picker.files()
				end,
				desc = "Find Files (Snacks Picker)",
			},
			{
				"<leader>pc",
				function()
					require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>ps",
				function()
					require("snacks").picker.grep()
					return {
						-- Mini Nvim
						{ "echasnovski/mini.nvim", version = false },
						-- Comments
						{
							"echasnovski/mini.comment",
							version = false,
							dependencies = {
								"JoosepAlviste/nvim-ts-context-commentstring",
							},
							config = function()
								-- disable the autocommand from ts-context-commentstring
								require("ts_context_commentstring").setup({
									enable_autocmd = false,
								})

								require("mini.comment").setup({
									-- tsx, jsx, html , svelte comment support
									options = {
										custom_commentstring = function()
											return require("ts_context_commentstring.internal").calculate_commentstring({
												key = "commentstring",
											}) or vim.bo.commentstring
										end,
									},
								})
							end,
						},
						-- File explorer (this works properly with oil unlike nvim-tree)
						{
							"echasnovski/mini.files",
							config = function()
								local MiniFiles = require("mini.files")
								MiniFiles.setup({
									mappings = {
										go_in = "<CR>", -- Map both Enter and L to enter directories or open files
										go_in_plus = "L",
										go_out = "-",
										go_out_plus = "H",
									},
								})
								vim.keymap.set(
									"n",
									"<leader>ee",
									"<cmd>lua MiniFiles.open()<CR>",
									{ desc = "Toggle mini file explorer" }
								) -- toggle file explorer
								vim.keymap.set("n", "<leader>ef", function()
									MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
									MiniFiles.reveal_cwd()
								end, { desc = "Toggle into currently opened file" })
							end,
						},
						-- Surround
						{
							"echasnovski/mini.surround",
							event = { "BufReadPre", "BufNewFile" },
							opts = {
								-- Add custom surroundings to be used on top of builtin ones. For more
								-- information with examples, see `:h MiniSurround.config`.
								custom_surroundings = nil,

								-- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
								highlight_duration = 300,

								-- Module mappings. Use `''` (empty string) to disable one.
								-- INFO:
								-- saiw surround with no whitespace
								-- saw surround with whitespace
								mappings = {
									add = "sa", -- Add surrounding in Normal and Visual modes
									delete = "ds", -- Delete surrounding
									find = "sf", -- Find surrounding (to the right)
									find_left = "sF", -- Find surrounding (to the left)
									highlight = "sh", -- Highlight surrounding
									replace = "sr", -- Replace surrounding
									update_n_lines = "sn", -- Update `n_lines`

									suffix_last = "l", -- Suffix to search with "prev" method
									suffix_next = "n", -- Suffix to search with "next" method
								},

								-- Number of lines within which surrounding is searched
								n_lines = 20,

								-- Whether to respect selection type:
								-- - Place surroundings on separate lines in linewise mode.
								-- - Place surroundings on each line in blockwise mode.
								respect_selection_type = false,

								-- How to search for surrounding (first inside current line, then inside
								-- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
								-- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
								-- see `:h MiniSurround.config`.
								search_method = "cover",

								-- Whether to disable showing non-error feedback
								silent = false,
							},
						},
						-- Get rid of whitespace
						{
							"echasnovski/mini.trailspace",
							event = { "BufReadPost", "BufNewFile" },
							config = function()
								local miniTrailspace = require("mini.trailspace")

								miniTrailspace.setup({
									only_in_normal_buffers = true,
								})
								vim.keymap.set("n", "<leader>cw", function()
									miniTrailspace.trim()
								end, { desc = "Erase Whitespace" })

								-- Ensure highlight never reappears by removing it on CursorMoved
								vim.api.nvim_create_autocmd("CursorMoved", {
									pattern = "*",
									callback = function()
										require("mini.trailspace").unhighlight()
									end,
								})
							end,
						},
						-- Split & join
						{
							"echasnovski/mini.splitjoin",
							config = function()
								local miniSplitJoin = require("mini.splitjoin")
								miniSplitJoin.setup({
									mappings = { toggle = "" }, -- Disable default mapping
								})
								vim.keymap.set({ "n", "x" }, "sj", function()
									miniSplitJoin.join()
								end, { desc = "Join arguments" })
								vim.keymap.set({ "n", "x" }, "sk", function()
									miniSplitJoin.split()
								end, { desc = "Split arguments" })
							end,
						},
					}
				end,
				desc = "Grep word",
			},
			{
				"<leader>pws",
				function()
					require("snacks").picker.grep_word()
				end,
				desc = "Search Visual selection or Word",
				mode = { "n", "x" },
			},
			{
				"<leader>pk",
				function()
					require("snacks").picker.keymaps({ layout = "ivy" })
				end,
				desc = "Search Keymaps (Snacks Picker)",
			},

			-- Git Stuff
			{
				"<leader>gbr",
				function()
					require("snacks").picker.git_branches({ layout = "select" })
				end,
				desc = "Pick and Switch Git Branches",
			},

			-- Other Utils
			{
				"<leader>th",
				function()
					require("snacks").picker.colorschemes({ layout = "ivy" })
				end,
				desc = "Pick Color Schemes",
			},
			{
				"<leader>vh",
				function()
					require("snacks").picker.help()
				end,
				desc = "Help Pages",
			},
		},
	},
	-- NOTE: todo comments w/ snacks
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPre", "BufNewFile" },
		optional = true,
		keys = {
			{
				"<leader>pt",
				function()
					require("snacks").picker.todo_comments()
				end,
				desc = "Todo",
			},
			{
				"<leader>pT",
				function()
					require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
				end,
				desc = "Todo/Fix/Fixme",
			},
		},
	},
}
