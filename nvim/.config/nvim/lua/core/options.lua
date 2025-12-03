-- NeoVim options configuration
-- General options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_matchit = 1        -- Disable enhanced % matching
vim.g.loaded_matchparen = 1     -- Disable highlight of matching parentheses
vim.g.loaded_tutor_mode_plugin = 1  -- Disable tutorial
vim.g.loaded_2html_plugin = 1   -- Disable 2html converter
vim.g.loaded_zipPlugin = 1      -- Disable zip file browsing
vim.g.loaded_tarPlugin = 1      -- Disable tar file browsing
vim.g.loaded_gzip = 1           -- Disable gzip file handling
vim.g.loaded_netrw = 1          -- Disable netrw (using nvim-tree instead)
vim.g.loaded_netrwPlugin = 1    -- Disable netrw plugin
vim.g.loaded_netrwSettings = 1  -- Disable netrw settings
vim.g.loaded_netrwFileHandlers = 1  -- Disable netrw file handlers
vim.g.loaded_spellfile_plugin = 1  -- Disable spellfile plugin

-- Ensure the built-in comment operator works for all filetypes
-- (Normally this is automatic — this is just for clarity)
vim.g.skip_ts_context_commentstring_module = true

-- Optional: automatically adjust commentstring when filetype changes
-- Most filetypes already set this, but you can override or add new ones here.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype

    -- Example overrides (customize these as needed)
    local map = {
      lua   = "-- %s",
      python = "# %s",
      c     = "// %s",
      cpp   = "// %s",
      html  = "<!-- %s -->",
      css   = "/* %s */",
      sh    = "# %s",
      bash  = "# %s",
      zsh   = "# %s",
      vim   = "\" %s",
    }

    if map[ft] then
      vim.bo.commentstring = map[ft]
    end
  end
})


-- Clipboard setup (use system clipboard as default)
vim.opt.clipboard:append("unnamedplus")
vim.opt.isfname:append("@-@")

-- General appearance and UI
local options = {
  nu = true,
  relativenumber = true,
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  autoindent = true,
  smartindent = true,
  wrap = false,
  swapfile = false,
  backup = false,
  undofile = true,
  incsearch = true,
  inccommand = "split",
  ignorecase = true,
  smartcase = true,
  termguicolors = true,
  background = "dark",
  scrolloff = 8,
  signcolumn = "yes",
  backspace = { "start", "eol", "indent" },
  splitright = true,
  splitbelow = true,
  updatetime = 50,
  colorcolumn = "100",  -- Column for line length limit
  hlsearch = true,      -- Highlight search results
  mouse = "a",          -- Enable mouse support
  timeoutlen = 100,     -- Time to wait for a mapped sequence to complete (in ms)
  writebackup = false,  -- Don't create backups of files being edited
  laststatus = 3,       -- Global status line
  fileencoding = "utf-8", -- File encoding
  guifont = "monospace:h17", -- Font used in GUI apps
  conceallevel = 0,     -- Show `` in markdown
  number = true,        -- Show line numbers
  numberwidth = 2,      -- Set width of number column
  fillchars = "eob: ",  -- Don't show tildes on empty lines
  cursorline = true,    -- Highlight current line
  showbreak = "  ",     -- Indentation for wrapped lines
  cmdheight = 1,        -- Command line height
  pumheight = 7,        -- Height of popup menu
  showmode = false,     -- Hide --INSERT-- mode
  sidescrolloff = 7,    -- Keep cursor within 7 columns of edge
  shortmess = "filnxtToOFcI", -- Suppress certain messages
  mousemoveevent = true, -- Enable mousemove events
  breakindent = true,   -- Enable line wrapping indentation
  linebreak = true,     -- Don't split words when wrapping
  spell = true,         -- Enable spell check
  spelllang = { 'en_us', 'de_de' }, -- Use US English dictionary
  clipboard = "unnamedplus", -- System clipboard access
  mousescroll = "ver:2,hor:4", -- Scroll speed for mouse
  virtualedit = "block", -- Virtual block cursor mode
  autoread = true,      -- Auto-reload files when changed externally
  foldenable = true,    -- Enable folding by default
  foldmethod = "manual", -- Folding method (manual)
  foldlevel = 99,       -- Open all folds by default
}

-- Apply all options
for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Auto-command for disabling tagjump in markdown
vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = {"markdown", "lectic.markdown"},
  callback = function()
    vim.opt_local.tagfunc = ""
  end
})

-- Persistent folding state (using custom.util)
local ok, utils = pcall(require, "util")
if not ok then
  vim.notify("Failed to load custom.util module", vim.log.levels.WARN)
end

-- Load folding state when entering any buffer
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = {"*"},
  callback = function()
    -- Use custom fold utility or fall back to global function
    local ok, fold_utils = pcall(require, "util.fold")
    if ok and fold_utils and fold_utils.load_folding_state then
      fold_utils.load_folding_state()
    elseif _G.LoadFoldingState then
      _G.LoadFoldingState()
    end
  end
})

-- URL handling
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      -- Use custom URL utility or fall back to global function
      local ok, url_utils = pcall(require, "util.url")
      if ok and url_utils and url_utils.setup_url_mappings then
        url_utils.setup_url_mappings()
      elseif _G.SetupUrlMappings then
        _G.SetupUrlMappings()
      end
    end, 200)
  end,
  once = true
})

-- Filetype-specific settings for markdown and tex (line wrapping)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "↳ "
  end,
})

-- Performance optimizations
vim.opt.lazyredraw = true        -- Reduce redraw frequency
vim.opt.updatetime = 300        -- Increase CursorHold time to reduce CPU usage
vim.opt.synmaxcol = 200         -- Limit syntax highlighting for better performance
vim.opt.redrawtime = 1500       -- Limit redraw time for better performance
vim.opt.history = 500           -- Limit history size
vim.opt.jumpoptions = "stack"   -- Optimize jump list
vim.opt.shada = "!,'100,<50,s10,h"  -- Optimize shada (session) storage
