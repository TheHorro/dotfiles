local keymap = vim.keymap.set

-- Nvim-tree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Telescope
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help" })

------------------------------------------
-- HELPER FUNCTIONS FOR KEYMAP SETUP   --
------------------------------------------
local opts = { noremap = true, silent = true }
-- Helper function for global keymap definitions with descriptions
local function map(mode, key, cmd, options, description)
  local opts = vim.tbl_deep_extend("force",
    { noremap = true, silent = true, desc = description },
    options or {}
  )
  vim.keymap.set(mode, key, cmd, opts)
end

-- Helper function for buffer-local keymap definitions
local function buf_map(bufnr, mode, key, cmd, description)
  vim.api.nvim_buf_set_keymap(
    bufnr or 0,
    mode,
    key,
    cmd,
    { noremap = true, silent = true, desc = description }
  )
end

----------------------------------------
-- BUFFER-SPECIFIC KEYMAP FUNCTIONS  --
----------------------------------------

-- Terminal-specific keybindings (called by terminal filetype autocmd)
function _G.set_terminal_keymaps()
  -- Lock terminal window to prevent buffer switching
  vim.wo.winfixbuf = true

  -- Check if this is a Claude Code terminal
  local bufname = vim.api.nvim_buf_get_name(0)

  -- Terminal navigation
  -- Skip escape mapping for Claude Code to allow its internal normal mode
  buf_map(0, "t", "<esc>", "<C-\\><C-n>", "Exit terminal mode")
  buf_map(0, "t", "<C-h>", "<Cmd>wincmd h<CR>", "Navigate left")
  buf_map(0, "t", "<C-j>", "<Cmd>wincmd j<CR>", "Navigate down")
  buf_map(0, "t", "<C-k>", "<Cmd>wincmd k<CR>", "Navigate up")
  buf_map(0, "t", "<C-l>", "<Cmd>wincmd l<CR>", "Navigate right")

  -- Terminal resizing
  buf_map(0, "t", "<M-Right>", "<Cmd>vertical resize -2<CR>", "Resize right")
  buf_map(0, "t", "<M-Left>", "<Cmd>vertical resize +2<CR>", "Resize left")
  buf_map(0, "t", "<M-l>", "<Cmd>vertical resize -2<CR>", "Resize right")
  buf_map(0, "t", "<M-h>", "<Cmd>vertical resize +2<CR>", "Resize left")

  -- Note: AI keybindings (C-c for Claude Code, C-g for Avante) are defined globally in this file
end

-- Markdown-specific keybindings (called by markdown filetype autocmd)
function _G.set_markdown_keymaps()
  -- Attempt to load autolist module for intelligent list management
  local ok, autolist = pcall(require, "plugins.tools.autolist.util")

  -- Configure markdown-appropriate tab settings
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2

  -- Configure keybindings with autolist integration if available
  if ok and autolist and autolist.operations then
    -- Smart list management through autolist handlers

    -- Intelligent Enter key handling for list continuation
    vim.keymap.set("i", "<CR>", autolist.operations.enter_handler,
      { expr = true, buffer = true, desc = "Smart list handling for Enter" })

    -- Smart tab handling for list indentation
    vim.keymap.set("i", "<Tab>", autolist.operations.tab_handler,
      { expr = true, buffer = true, desc = "Smart list indent" })

    vim.keymap.set("i", "<S-Tab>", autolist.operations.shift_tab_handler,
      { expr = true, buffer = true, desc = "Smart list unindent" })

    vim.keymap.set("i", "<C-D>", autolist.operations.shift_tab_handler,
      { expr = true, buffer = true, desc = "Smart list unindent (C-D)" })

    -- Normal mode list operations
    vim.keymap.set("n", "<C-n>", "<cmd>AutolistIncrementCheckbox<CR>",
      { buffer = true, desc = "Increment checkbox" })

    vim.keymap.set("n", "<A-n>", "<cmd>AutolistDecrementCheckbox<CR>",
      { buffer = true, desc = "Decrement checkbox" })

    vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>",
      { buffer = true, desc = "New bullet below" })

    vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>",
      { buffer = true, desc = "New bullet above" })

    vim.keymap.set("n", ">", "><cmd>AutolistRecalculate<cr>",
      { buffer = true, desc = "Indent bullet" })

    vim.keymap.set("n", "<", "<<cmd>AutolistRecalculate<cr>",
      { buffer = true, desc = "Unindent bullet" })

    -- List recalculation is handled by <leader>rr in which-key

    -- Smart deletion that maintains list consistency
    vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>",
      { buffer = true, desc = "Delete and recalculate" })

    vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>",
      { buffer = true, desc = "Delete and recalculate" })
  else
    -- Fallback keybindings when autolist module is unavailable
    buf_map(0, "i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", "New bullet point")
    buf_map(0, "n", "o", "o<cmd>AutolistNewBullet<cr>", "New bullet below")
    buf_map(0, "n", "O", "O<cmd>AutolistNewBulletBefore<cr>", "New bullet above")
    buf_map(0, "n", "<C-n>", "<cmd>lua IncrementCheckbox()<CR>", "Increment checkbox")
    buf_map(0, "n", "<A-n>", "<cmd>lua DecrementCheckbox()<CR>", "Decrement checkbox")
  end
end

---------------------------------
-- GLOBAL KEYBOARD MAPPINGS   --
---------------------------------
keymap({"n", "x"}, "gc", function() 
  return require("vim._comment").operator()
end, {expr = true, desc = "Comment current line"})
-- keymap("x", "gc", "gc", {}, "Linewise block comment")


keymap("n", "gcc", function()
  return require("vim._comment").operator_line()
end, { expr = true, desc = "Toggle comment on current line" })

-- Extra helpers similar to vim‑commentary / mini.comment. [web:1]
keymap("n", "gco", function()
  -- Comment a new line below and enter insert mode
  return require("vim._comment").insert_below()
end, { expr = true, desc = "Add comment on line below" })

keymap("n", "gcO", function()
  -- Comment a new line above and enter insert mode
  return require("vim._comment").insert_above()
end, { expr = true, desc = "Add comment on line above" })

keymap("n", "gcA", function()
  -- Append comment at end of current line and enter insert mode
  return require("vim._comment").append_end_of_line()
end, { expr = true, desc = "Add comment at end of line" })

-- Disable potentially problematic default mappings
map("n", "<C-z>", "<nop>", {}, "Disable suspend")

-- Terminal window management
map("n", "<C-t>", "<cmd>ToggleTerm<CR>", { remap = true }, "Toggle terminal")
map("t", "<C-t>", "<cmd>ToggleTerm<CR>", { remap = true }, "Toggle terminal")

-- Telescope-based spelling suggestions
map("n", "<C-s>", function()
  require("telescope.builtin").spell_suggest(require("telescope.themes").get_cursor({
    previewer = false,
    layout_config = { width = 50, height = 15 }
  }))
end, { remap = true }, "Spelling suggestions")

-- Search and file finding
map("n", "<CR>", "<cmd>noh<CR>", {}, "Clear search highlights")
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { remap = true }, "Find files")

-- Documentation and help access
map("n", "<S-m>", '<cmd>Telescope help_tags cword=true<cr>', {}, "Help for word under cursor")
map("n", "<C-m>", '<cmd>Telescope man_pages<cr>', {}, "Search man pages")
------------------------
-- TEXT EDITING KEYS --
------------------------

-- Improved default text manipulation behaviors
map("n", "Y", "y$", {}, "Yank to end of line")
map("n", "E", "ge", {}, "Go to end of previous word")
map("v", "Y", "y$", {}, "Yank to end of line")

-- Screen positioning and cursor centering
map("n", "m", "zt", {}, "Center cursor at top")
map("v", "m", "zt", {}, "Center cursor at top")

-- Window navigation using Ctrl+hjkl
map("n", "<C-h>", "<C-w>h", {}, "Navigate left")
map("n", "<C-j>", "<C-w>j", {}, "Navigate down")
map("n", "<C-k>", "<C-w>k", {}, "Navigate up")
map("n", "<C-l>", "<C-w>l", {}, "Navigate right")

-- Window resizing with Alt+arrows and Alt+hl
map("n", "<A-Left>", ":vertical resize -2<CR>", {}, "Decrease width")
map("n", "<A-Right>", ":vertical resize +2<CR>", {}, "Increase width")
map("n", "<A-h>", ":vertical resize -2<CR>", {}, "Decrease width")
map("n", "<A-l>", ":vertical resize +2<CR>", {}, "Increase width")

-- Smart buffer navigation with fallback chain
local buffer_utils_loaded = false

-- Attempt to load advanced buffer utilities
local ok, buffer_utils = pcall(require, "custom.util.buffer")
if ok and buffer_utils and buffer_utils.goto_buffer then
  buffer_utils_loaded = true

  -- Use intelligent buffer switching (sorted by modification time)
  map("n", "<TAB>", function() buffer_utils.goto_buffer(1, 1) end, {}, "Next buffer")
  map("n", "<S-TAB>", function() buffer_utils.goto_buffer(1, -1) end, {}, "Previous buffer")

  -- Restore <C-i> for jump-forward navigation (requires Kitty keyboard protocol)
  -- Note: <C-i> and <Tab> send identical keycodes in traditional terminals.
  -- Modern keyboard protocols (Kitty, CSI u) can distinguish them.
  -- This mapping ensures <C-i> jumps forward in jump list when protocol is enabled.
  map("n", "<C-i>", "<C-i>", { noremap = true }, "Jump forward in jump list")
end

-- Fallback chain if advanced utils are unavailable
if not buffer_utils_loaded then
  -- Try global function if available
  if _G.GotoBuffer then
    map("n", "<TAB>", function() _G.GotoBuffer(1, 1) end, {}, "Next buffer")
    map("n", "<S-TAB>", function() _G.GotoBuffer(1, -1) end, {}, "Previous buffer")
    map("n", "<C-i>", "<C-i>", { noremap = true }, "Jump forward in jump list")
  else
    -- Safe buffer navigation that excludes terminal and unlisted buffers
    local function safe_buffer_next()
      local buffers = vim.fn.getbufinfo({ buflisted = 1 })
      local normal_buffers = {}

      for _, buf in ipairs(buffers) do
        -- Only include normal buffers (not terminals)
        if vim.api.nvim_buf_is_valid(buf.bufnr) and 
          vim.api.nvim_buf_get_option(buf.bufnr, 'buftype') == '' then
          table.insert(normal_buffers, buf)
        end
      end

      if #normal_buffers > 1 then
        local current = vim.fn.bufnr('%')
        local current_index = 1
        for i, buf in ipairs(normal_buffers) do
          if buf.bufnr == current then
            current_index = i
            break
          end
        end

        local next_index = current_index >= #normal_buffers and 1 or current_index + 1
        vim.cmd('buffer ' .. normal_buffers[next_index].bufnr)
      end
    end

    local function safe_buffer_prev()
      local buffers = vim.fn.getbufinfo({ buflisted = 1 })
      local normal_buffers = {}

      for _, buf in ipairs(buffers) do
        -- Only include normal buffers (not terminals)
        if vim.api.nvim_buf_is_valid(buf.bufnr) and 
          vim.api.nvim_buf_get_option(buf.bufnr, 'buftype') == '' then
          table.insert(normal_buffers, buf)
        end
      end

      if #normal_buffers > 1 then
        local current = vim.fn.bufnr('%')
        local current_index = 1
        for i, buf in ipairs(normal_buffers) do
          if buf.bufnr == current then
            current_index = i
            break
          end
        end

        local prev_index = current_index <= 1 and #normal_buffers or current_index - 1
        vim.cmd('buffer ' .. normal_buffers[prev_index].bufnr)
      end
    end

    map("n", "<TAB>", safe_buffer_next, {}, "Next buffer")
    map("n", "<S-TAB>", safe_buffer_prev, {}, "Previous buffer")
    map("n", "<C-i>", "<C-i>", { noremap = true }, "Jump forward in jump list")
  end
end

-- Line and selection movement with Alt+jk
map("n", "<A-j>", "<Esc>:m .+1<CR>==", {}, "Move line down")
map("n", "<A-k>", "<Esc>:m .-2<CR>==", {}, "Move line up")
map("x", "<A-j>", ":move '>+1<CR>gv-gv", {}, "Move selection down")
map("x", "<A-k>", ":move '<-2<CR>gv-gv", {}, "Move selection up")
map("v", "<A-j>", ":m'>+<CR>gv", {}, "Move selection down")
map("v", "<A-k>", ":m-2<CR>gv", {}, "Move selection up")

-- Enhanced scrolling that keeps cursor centered
map("n", "<c-u>", "<c-u>zz", {}, "Scroll up with centering")
map("n", "<c-d>", "<c-d>zz", {}, "Scroll down with centering")

-- Quickfix list navigation (centered cursor for visibility)
map("n", "]q", "<cmd>cnext<cr>zz", {}, "Next quickfix item")
map("n", "[q", "<cmd>cprev<cr>zz", {}, "Previous quickfix item")
map("n", "]Q", "<cmd>clast<cr>zz", {}, "Last quickfix item")
map("n", "[Q", "<cmd>cfirst<cr>zz", {}, "First quickfix item")

-- Location list navigation (buffer-local quickfix)
map("n", "]l", "<cmd>lnext<cr>zz", {}, "Next location list item")
map("n", "[l", "<cmd>lprev<cr>zz", {}, "Previous location list item")
map("n", "]L", "<cmd>llast<cr>zz", {}, "Last location list item")
map("n", "[L", "<cmd>lfirst<cr>zz", {}, "First location list item")

-- Display line navigation (respects word wrapping)
map("v", "<S-h>", "g^", {}, "Go to start of display line")
map("v", "<S-l>", "g$", {}, "Go to end of display line")
map("n", "<S-h>", "g^", {}, "Go to start of display line")
map("n", "<S-l>", "g$", {}, "Go to end of display line")

-- Smart indentation that preserves selection
map("v", "<", "<gv", {}, "Decrease indent and reselect")
map("v", ">", ">gv", {}, "Increase indent and reselect")
map("n", "<", "<S-v><<esc>", {}, "Decrease indent for line")
map("n", ">", "<S-v>><esc>", {}, "Increase indent for line")

-- Visual line navigation (J/K for wrapped lines)
map("n", "J", "gj", {}, "Move down display line")
map("n", "K", "gk", {}, "Move up display line")
map("v", "J", "gj", {}, "Move down display line")
map("v", "K", "gk", {}, "Move up display line")


