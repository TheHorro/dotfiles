-- plugins.editor.which-key
-- Keybinding configuration and display using which-key.nvim v3 API

--[[ WHICH-KEY MAPPINGS - COMPLETE REFERENCE
-----------------------------------------------------------

This module configures which-key.nvim using the modern v3 API with icon support.
All mappings are organized alphabetically by leader letter and use `cond` functions
for filetype-specific features instead of autocmds.

The configuration provides:
- Helper functions for filetype detection
- All mappings grouped by letter with conditional visibility
- Clean separation of concerns without autocmd pollution

----------------------------------------------------------------------------------
TOP-LEVEL MAPPINGS (<leader>)                   | DESCRIPTION
----------------------------------------------------------------------------------
<leader>c - Create vertical split               | Split window vertically
<leader>d - Save and delete buffer              | Save file and close buffer
<leader>e - Toggle NvimTree explorer            | Open/close file explorer
<leader>k - Kill/close split                    | Close current split window
<leader>q - Save all and quit                   | Save all files and exit Neovim
<leader>u - Open Telescope undo                 | Show undo history with preview
<leader>w - Write all files                     | Save all open files

[Additional documentation continues as before...]
]] --

-- Import notification module for TTS toggle functionality
local notify = require('util.notifications')

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    -- 'echasnovski/mini.nvim',
  },
  opts = {
    preset = "classic",
    delay = function(ctx)
      return ctx.plugin and 0 or 200
    end,
    show_help = false,    -- Remove bottom help/status bar
    show_keys = false,    -- Remove key hints
    win = {
      border = "rounded",
      padding = { 1, 2 },
      title = false,
      title_pos = "center",
      zindex = 1000,
      wo = {
        winblend = 10,
      },
      bo = {
        filetype = "which_key",
        buftype = "nofile",
      },
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    layout = {
      width = { min = 20, max = 50 },
      height = { min = 4, max = 25 },
      spacing = 3,
      align = "left",
    },
    keys = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    sort = { "local", "order", "group", "alphanum", "mod" },
    disable = {
      bt = { "help", "quickfix", "terminal", "prompt" },
      ft = { "neo-tree" }
    },
    triggers = {
      { "<leader>", mode = { "n", "v" } }
    }
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- ============================================================================
    -- HELPER FUNCTIONS FOR FILETYPE DETECTION
    -- ============================================================================

    -- Toggle TTS_ENABLED in the project-specific config file
    -- @param config_path string Path to the tts-config.sh file
    -- @return success boolean True if toggle succeeded
    -- @return message string Success message ("TTS enabled" or "TTS disabled")
    -- @return error string Error message if success is false
    local function toggle_tts_config(config_path)
      -- Validate file exists (redundant check, but safe)
      if vim.fn.filereadable(config_path) ~= 1 then
        return false, nil, "Config file not readable: " .. config_path
      end

      -- Read file with error handling
      local ok, lines = pcall(vim.fn.readfile, config_path)
      if not ok then
        return false, nil, "Failed to read config: " .. tostring(lines)
      end

      -- Find and toggle TTS_ENABLED
      local modified = false
      local message
      for i, line in ipairs(lines) do
        if line:match("^TTS_ENABLED=") then
          if line:match("=true$") then
            lines[i] = "TTS_ENABLED=false"
            message = "TTS disabled"
          else
            lines[i] = "TTS_ENABLED=true"
            message = "TTS enabled"
          end
          modified = true
          break
        end
      end

      if not modified then
        return false, nil, "TTS_ENABLED not found in config file"
      end

      -- Write file with error handling
      local write_ok, write_err = pcall(vim.fn.writefile, lines, config_path)
      if not write_ok then
        return false, nil, "Failed to write config: " .. tostring(write_err)
      end

      return true, message, nil
    end

    local function is_latex()
      return vim.tbl_contains({ "tex", "latex", "bib", "cls", "sty" }, vim.bo.filetype)
    end

    local function is_python()
      return vim.bo.filetype == "python"
    end

    local function is_markdown()
      return vim.tbl_contains({ "markdown", "md" }, vim.bo.filetype)
    end

    local function is_lectic()
      return vim.tbl_contains({ "lec", "markdown", "md" }, vim.bo.filetype)
    end

    local function is_jupyter()
      return vim.bo.filetype == "ipynb"
    end

    local function is_jupyter_or_python()
      return vim.bo.filetype == "ipynb" or vim.bo.filetype == "python"
    end

    local function is_lean()
      return vim.bo.filetype == "lean"
    end

    local function is_pandoc_compatible()
      return vim.tbl_contains({ "markdown", "md", "tex", "latex", "org", "rst", "html", "docx" }, vim.bo.filetype)
    end

    -- ============================================================================
    -- TOP-LEVEL SINGLE KEY MAPPINGS
    -- ============================================================================

    wk.add({
      { "<leader>c", "<cmd>vert sb<CR>", desc = "create split", icon = "󰯌" },
      { "<leader>d", "<cmd>update! | lua Snacks.bufdelete()<CR>", desc = "delete buffer", icon = "󰩺" },
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "explorer", icon = "󰙅" },
      { "<leader>k", "<cmd>close<CR>", desc = "kill split", icon = "󰆴" },
      { "<leader>q", "<cmd>wa! | qa!<CR>", desc = "write quit", icon = "󰗼" },
      { "<leader>u", "<cmd>Telescope undo<CR>", desc = "undo", icon = "󰕌" },
      { "<leader>w", "<cmd>wa!<CR>", desc = "write", icon = "󰆓" },
    })

    -- ============================================================================
    -- <leader>f - FIND GROUP
    -- ============================================================================

    wk.add({
      { "<leader>f", group = "find", icon = "󰍉", mode = { "n", "v" } },
      { "<leader>fa", "<cmd>lua require('telescope.builtin').find_files({ no_ignore = true, hidden = true, search_dirs = { '~/' } })<CR>", desc = "all files", icon = "󰈙" },
      { "<leader>fb", "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<CR>", desc = "buffers", icon = "󰓩" },
      { "<leader>fc", "<cmd>Telescope bibtex format_string=\\citet{%s}<CR>", desc = "citations", icon = "󰈙" },
      { "<leader>ff", "<cmd>Telescope live_grep theme=ivy<CR>", desc = "project", icon = "󰊄" },
      { "<leader>fl", "<cmd>Telescope resume<CR>", desc = "last search", icon = "󰺄" },
      { "<leader>fp", "<cmd>lua require('util.misc').copy_buffer_path()<CR>", desc = "copy buffer path", icon = "󰆏" },
      { "<leader>fq", "<cmd>Telescope quickfix<CR>", desc = "quickfix", icon = "󰁨" },
      { "<leader>fg", "<cmd>Telescope git_commits<CR>", desc = "git history", icon = "󰊢" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "help", icon = "󰞋" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "keymaps", icon = "󰌌" },
      { "<leader>fr", "<cmd>Telescope registers<CR>", desc = "registers", icon = "󰊄" },
      { "<leader>fs", "<cmd>Telescope grep_string<CR>", desc = "string", icon = "󰊄", mode = { "n", "v" } },
      { "<leader>fw", "<cmd>lua SearchWordUnderCursor()<CR>", desc = "word", icon = "󰊄", mode = { "n", "v" } },
      { "<leader>fy", function() _G.YankyTelescopeHistory() end, desc = "yanks", icon = "󰆏", mode = { "n", "v" } },
    })

    -- ============================================================================
    -- <leader>g - GIT GROUP
    -- ============================================================================

    wk.add({
      { "<leader>g", group = "git", icon = "󰊢", mode = { "n", "v" } },
      { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "branches", icon = "󰘬" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits", icon = "󰜘" },
      { "<leader>gd", "<cmd>Gitsigns diffthis HEAD<CR>", desc = "diff HEAD", icon = "󰦓" },
      -- { "<leader>gf", "<cmd>Telescope git_worktree create_git_worktree<CR>", desc = "new feature", icon = "󰊕" },
      { "<leader>gg", function() require("snacks").lazygit() end, desc = "lazygit", icon = "󰊢" },
      { "<leader>gh", "<cmd>Gitsigns prev_hunk<CR>", desc = "prev hunk", icon = "󰮲" },
      { "<leader>gj", "<cmd>Gitsigns next_hunk<CR>", desc = "next hunk", icon = "󰮰" },
      { "<leader>gl", "<cmd>Gitsigns blame_line<CR>", desc = "line blame", icon = "󰊢", mode = { "n", "v" } },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", desc = "preview hunk", icon = "󰆈" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status", icon = "󰊢" },
      { "<leader>gt", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "toggle blame", icon = "󰔡" },
    })

    -- ============================================================================
    -- <leader>h - HELP GROUP
    -- ============================================================================

    wk.add({
      { "<leader>h", group = "help", icon = "󰞋" },
      { "<leader>ha", "<cmd>Telescope autocommands<CR>", desc = "autocommands", icon = "󰆘" },
      { "<leader>hc", "<cmd>Telescope commands<CR>", desc = "commands", icon = "󰘳" },
      { "<leader>hh", "<cmd>Telescope help_tags<CR>", desc = "help tags", icon = "󰞋" },
      { "<leader>hH", "<cmd>Telescope highlights<CR>", desc = "highlights", icon = "󰸱" },
      { "<leader>hk", "<cmd>Telescope keymaps<CR>", desc = "keymaps", icon = "󰌌" },
      { "<leader>hl", "<cmd>LspInfo<CR>", desc = "lsp info", icon = "󰅴" },
      { "<leader>hL", "<cmd>Lazy<CR>", desc = "lazy plugin manager", icon = "󰒲" },
      { "<leader>hm", "<cmd>Telescope man_pages<CR>", desc = "man pages", icon = "󰈙" },
      { "<leader>hM", "<cmd>Mason<CR>", desc = "mason lsp installer", icon = "󰏖" },
      { "<leader>hn", "<cmd>NullLsInfo<CR>", desc = "null-ls info", icon = "󰅴" },
      { "<leader>ho", "<cmd>Telescope vim_options<CR>", desc = "vim options", icon = "󰒕" },
      { "<leader>hr", "<cmd>Telescope reloader<CR>", desc = "reload modules", icon = "󰜉" },
      { "<leader>ht", "<cmd>TSPlaygroundToggle<CR>", desc = "treesitter playground", icon = "󰔡" },
    })

    -- ============================================================================
    -- <leader>i - LSP & LINT GROUP
    -- ============================================================================

    wk.add({
      { "<leader>i", group = "lsp", icon = "󰅴", mode = { "n", "v" } },
      { "<leader>ib", "<cmd>Telescope diagnostics bufnr=0<CR>", desc = "buffer diagnostics", icon = "󰒓" },
      { "<leader>iB", "<cmd>LintToggle buffer<CR>", desc = "toggle buffer linting", icon = "󰔡" },
      { "<leader>ic", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "code action", icon = "󰌵", mode = { "n", "v" } },
      { "<leader>id", "<cmd>Telescope lsp_definitions<CR>", desc = "definition", icon = "󰳦" },
      { "<leader>iD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "declaration", icon = "󰳦" },
      { "<leader>ig", "<cmd>LintToggle<CR>", desc = "toggle global linting", icon = "󰔡" },
      { "<leader>ih", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "help", icon = "󰞋" },
      { "<leader>ii", "<cmd>Telescope lsp_implementations<CR>", desc = "implementations", icon = "󰡱" },
      { "<leader>il", "<cmd>lua vim.diagnostic.open_float()<CR>", desc = "line diagnostics", icon = "󰒓" },
      { "<leader>iL", function() require("lint").try_lint() end, desc = "lint file", icon = "󰁨" },
      { "<leader>in", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "next diagnostic", icon = "󰮰" },
      { "<leader>ip", "<cmd>lua vim.diagnostic.goto_prev()<CR>", desc = "previous diagnostic", icon = "󰮲" },
      { "<leader>ir", "<cmd>Telescope lsp_references<CR>", desc = "references", icon = "󰌹" },
      { "<leader>iR", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "rename", icon = "󰑕" },
      { "<leader>is", "<cmd>LspRestart<CR>", desc = "restart lsp", icon = "󰜉" },
      { "<leader>it", function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
          vim.cmd('LspStop')
          require('util.notifications').lsp('LSP stopped', require('util.notifications').categories.USER_ACTION)
        else
          vim.cmd('LspStart')
          require('util.notifications').lsp('LSP started', require('util.notifications').categories.USER_ACTION)
        end
      end, desc = "toggle lsp", icon = "󰔡" },
      { "<leader>iy", "<cmd>lua CopyDiagnosticsToClipboard()<CR>", desc = "copy diagnostics", icon = "󰆏" },
    })

    -- ============================================================================
    -- <leader>l - LATEX GROUP
    -- ============================================================================

    wk.add({
      -- Group header (static name, conditional visibility)
      { "<leader>l", group = "latex", icon = "󰙩", cond = is_latex },

      -- LaTeX-specific mappings
      { "<leader>la", "<cmd>lua PdfAnnots()<CR>", desc = "annotate", icon = "󰏪", cond = is_latex },
      { "<leader>lb", "<cmd>terminal bibexport -o %:p:r.bib %:p:r.aux<CR>", desc = "bib export", icon = "󰈝", cond = is_latex },
      { "<leader>lc", "<cmd>VimtexCompile<CR>", desc = "compile", icon = "󰖷", cond = is_latex },
      { "<leader>le", "<cmd>VimtexErrors<CR>", desc = "errors", icon = "󰅚", cond = is_latex },
      { "<leader>lf", "<cmd>terminal latexindent -w %:p:r.tex<CR>", desc = "format", icon = "󰉣", cond = is_latex },
      { "<leader>lg", "<cmd>e ~/.config/nvim/templates/Glossary.tex<CR>", desc = "glossary", icon = "󰈚", cond = is_latex },
      { "<leader>li", "<cmd>VimtexTocOpen<CR>", desc = "index", icon = "󰋽", cond = is_latex },
      { "<leader>lk", "<cmd>VimtexClean<CR>", desc = "kill aux", icon = "󰩺", cond = is_latex },
      { "<leader>lm", "<plug>(vimtex-context-menu)", desc = "menu", icon = "󰍉", cond = is_latex },
      { "<leader>lv", "<cmd>VimtexView<CR>", desc = "view", icon = "󰛓", cond = is_latex },
      { "<leader>lw", "<cmd>VimtexCountWords!<CR>", desc = "word count", icon = "󰆿", cond = is_latex },
      { "<leader>lx", "<cmd>:VimtexClearCache All<CR>", desc = "clear cache", icon = "󰃢", cond = is_latex },
    })

    -- ============================================================================
    -- <leader>p - PANDOC GROUP
    -- ============================================================================

    wk.add({
      -- Group header (static name, conditional visibility)
      { "<leader>p", group = "pandoc", icon = "󰈙", cond = is_pandoc_compatible },

      -- Pandoc-specific mappings
      { "<leader>ph", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.html'<CR>", desc = "html", icon = "󰌝", cond = is_pandoc_compatible },
      { "<leader>pl", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.tex'<CR>", desc = "latex", icon = "󰐺", cond = is_pandoc_compatible },
      { "<leader>pm", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.md'<CR>", desc = "markdown", icon = "󱀈", cond = is_pandoc_compatible },
      { "<leader>pp", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.pdf' open=0<CR>", desc = "pdf", icon = "󰈙", cond = is_pandoc_compatible },
      { "<leader>pv", "<cmd>TermExec cmd='sioyek %:p:r.pdf &' open=0<CR>", desc = "view", icon = "󰛓", cond = is_pandoc_compatible },
      { "<leader>pw", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.docx'<CR>", desc = "word", icon = "󰈭", cond = is_pandoc_compatible },
    })

    -- ============================================================================
    -- <leader>r - RUN GROUP
    -- ============================================================================

    wk.add({
      { "<leader>r", group = "run", icon = "󰌵" },
      { "<leader>rc", "<cmd>TermExec cmd='rm -rf ~/.cache/nvim' open=0<CR>", desc = "clear plugin cache", icon = "󰃢" },
      { "<leader>rd", function()
          local notify = require('util.notifications')
          notify.toggle_debug_mode()
        end, desc = "toggle debug mode", icon = "󰃤" },
      { "<leader>rl", "<cmd>lua require('util.diagnostics').show_all_errors()<CR>", desc = "show linter errors", icon = "󰅚" },
      { "<leader>rf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "format", icon = "󰉣", mode = { "n", "v" } },
      { "<leader>rF", "<cmd>lua ToggleAllFolds()<CR>", desc = "toggle all folds", icon = "󰘖" },
      { "<leader>rh", "<cmd>LocalHighlightToggle<CR>", desc = "highlight", icon = "󰠷" },
      { "<leader>rk", "<cmd>BufDeleteFile<CR>", desc = "kill file and buffer", icon = "󰆴" },
      { "<leader>rK", "<cmd>TermExec cmd='rm -rf ~/.local/share/nvim/lazy && rm -f ~/.config/nvim/lazy-lock.json' open=0<CR>", desc = "wipe plugins and lock file", icon = "󰩺" },
      { "<leader>ri", "<cmd>LeanInfoviewToggle<CR>", desc = "lean info", icon = "󰊕", cond = is_lean },
      { "<leader>rm", "<cmd>lua RunModelChecker()<CR>", desc = "model checker", icon = "󰐊", mode = "n" },
      { "<leader>rM", "<cmd>lua Snacks.notifier.show_history()<cr>", desc = "show messages", icon = "󰍡" },
      { "<leader>ro", "za", desc = "toggle fold under cursor", icon = "󰘖" },
      { "<leader>rp", "<cmd>TermExec cmd='python %:p:r.py'<CR>", desc = "python run", icon = "󰌠", cond = is_python },
      { "<leader>rr", "<cmd>AutolistRecalculate<CR>", desc = "reorder list", icon = "󰔢", cond = is_markdown },
      { "<leader>rR", "<cmd>ReloadConfig<cr>", desc = "reload configs", icon = "󰜉" },
      { "<leader>re", "<cmd>Neotree ~/.config/nvim/snippets/<CR>", desc = "snippets edit", icon = "󰩫" },
      { "<leader>rt", "<cmd>lua ToggleFoldingMethod()<CR>", desc = "toggle folding method", icon = "󰘖" },
      { "<leader>ru", "<cmd>cd %:p:h | Neotree reveal<CR>", desc = "update cwd", icon = "󰉖" },
      { "<leader>rg", "<cmd>lua OpenUrlUnderCursor()<CR>", desc = "go to URL", icon = "󰖟" },
    })

    -- ============================================================================
    -- <leader>s - SURROUND GROUP
    -- ============================================================================
    --
    -- wk.add({
    --   { "<leader>s", group = "surround", icon = "󰅪", mode = { "n", "v" } },
    --   { "<leader>sc", "<Plug>(nvim-surround-change)", desc = "change", icon = "󰏫" },
    --   { "<leader>sd", "<Plug>(nvim-surround-delete)", desc = "delete", icon = "󰚌" },
    --   { "<leader>ss", "<Plug>(nvim-surround-normal)", desc = "surround", icon = "󰅪", mode = "n" },
    --   { "<leader>ss", "<Plug>(nvim-surround-visual)", desc = "surround selection", icon = "󰅪", mode = "v" },
    -- })
    --
    -- ============================================================================
    -- <leader>S - SESSIONS GROUP
    -- ============================================================================

    wk.add({
      { "<leader>S", group = "sessions", icon = "󰆔" },
      { "<leader>Sd", "<cmd>SessionManager delete_session<CR>", desc = "delete", icon = "󰚌" },
      { "<leader>Sl", "<cmd>SessionManager load_session<CR>", desc = "load", icon = "󰉖" },
      { "<leader>Ss", "<cmd>SessionManager save_current_session<CR>", desc = "save", icon = "󰆓" },
    })

    -- ============================================================================
    -- <leader>t - TODO GROUP
    -- ============================================================================

    wk.add({
      { "<leader>t", group = "todo", icon = "󰄬" },
      { "<leader>tl", "<cmd>TodoLocList<CR>", desc = "todo location list", icon = "󰈙" },
      { "<leader>tn", function() require("todo-comments").jump_next() end, desc = "next todo", icon = "󰮰" },
      { "<leader>tp", function() require("todo-comments").jump_prev() end, desc = "previous todo", icon = "󰮲" },
      { "<leader>tq", "<cmd>TodoQuickFix<CR>", desc = "todo quickfix", icon = "󰁨" },
      { "<leader>tt", "<cmd>TodoTelescope<CR>", desc = "todo telescope", icon = "󰄬" },
    })

    -- ============================================================================
    -- <leader>x - TROUBLE GROUP
    -- ============================================================================

    wk.add({
      { "<leader>x", group = "trouble", icon = "󰤌", mode = { "n", "v" } },
      { "<leader>xd", desc = "document diagnostics", icon = "󰦓" },
      { "<leader>xs", desc = "split/join toggle", icon = "󰤋", mode = { "n", "v" } },
      { "<leader>xq", desc = "quickfix list", icon="", mode = {"n", "v"}},
      { "<leader>xl", desc = "location list", icon="", mode = {"n", "v"}},
      { "<leader>xt", desc = "todos", icon="", mode = {"n", "v"}},
      { "<leader>xw", desc = "workspace diagnostics" , icon = "󰦓" },
    })
    -- ============================================================================
    -- <leader>T - TEXT group
    -- ============================================================================

    wk.add({
      { "<leader>T", group = "Text", icon = "󰤌", mode = { "n", "v" } },
      { "<leader>Ta", desc = "align", icon = "󰉞", mode = { "n", "v" } },
      { "<leader>TA", desc = "align with preview", icon = "󰉞", mode = { "n", "v" } },
      { "<leader>Tf", desc = "ALE fix", icon = "󰉞", mode = { "n", "v" } },
    })


    -- ============================================================================
    -- <leader>y - YANK GROUP
    -- ============================================================================

    wk.add({
      { "<leader>y", group = "yank", icon = "󰆏", mode = { "n", "v" } },
      { "<leader>yc", function() require("yanky").clear_history() end, desc = "clear history", icon = "󰃢" },
      { "<leader>yh", function() _G.YankyTelescopeHistory() end, desc = "yank history", icon = "󰞋", mode = { "n", "v" } },
    })
  end,
}
