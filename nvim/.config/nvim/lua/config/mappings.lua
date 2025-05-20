vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", {})
vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})

vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})

local cmp = require("cmp")
vim.keymap.set("n", "<C-b>", cmp.mapping.scroll_docs(-4), {})
vim.keymap.set("n", "<C-f>", cmp.mapping.scroll_docs(4), {})
vim.keymap.set("n", "<C-Spaca>", cmp.mapping.complete(), {})
vim.keymap.set("n", "<C-e>", cmp.mapping.abort(), {})
vim.keymap.set("n", "<CR>", cmp.mapping.confirm({ select = true }), {})
