return {
  "lervag/vimtex",
  init = function()
    -- Indentation settings
    vim.g.vimtex_indent_enabled = false            -- Disable auto-indent from Vimtex
    vim.g.tex_indent_items = false                 -- Disable indent for enumerate
    vim.g.tex_indent_brace = false                 -- Disable brace indent

    -- Compiler settings
    vim.g.vimtex_compiler_method = 'latexmk'       -- Explicit compiler backend selection
    vim.g.vimtex_compiler_latexmk = {              -- latexmk configuration
      backend = "nvim",
      background = 1,
      build_dir = "out",     -- PDF will go to ./out/
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      hooks = {},
      options = {
        '-xelatex',                                -- Use XeLaTeX engine
        '-interaction=nonstopmode',                -- Don't stop on errors
        '-file-line-error',                        -- Better error messages
        '-synctex=1',                              -- Enable SyncTeX
      },
    }
    -- Viewer settings
    vim.g.vimtex_view_method = 'zathura'            -- Sioyek PDF viewer for academic documents
    -- Note: Not setting vimtex_view_sioyek_options allows VimTeX to handle window management
    -- It will open new windows when needed but reuse for the same document
    vim.g.vimtex_context_pdf_viewer = 'okular'     -- External PDF viewer for the Vimtex menu

    -- Formatting settings
    -- vim.g.vimtex_format_enabled = true             -- Enable formatting with latexindent
    -- vim.g.vimtex_format_program = 'latexindent'

    -- Quickfix settings
    vim.g.vimtex_quickfix_mode = 0                 -- Open quickfix window on errors (2 = auto-close when empty)
    vim.g.vimtex_quickfix_autoclose_after_keystrokes = 2
    vim.g.vimtex_quickfix_ignore_filters = {       -- Filter out common noise
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
      'Package hyperref Warning',
      'Unused Label',
    }
    vim.g.vimtex_log_ignore = {                    -- Suppress specific log messages
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
      'Unused Label',
    }

    -- Other settings
    vim.g.vimtex_mappings_enabled = false          -- Disable default mappings
    vim.g.tex_flavor = 'latex'                     -- Set file type for TeX files
  end,

  config = function()
    -- =====================
    -- Keymaps
    -- =====================
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
    end

    -- Compiler
    map("<leader>ll", "<cmd>VimtexCompile<cr>", "VimTeX: Start compilation")
    map("<leader>lk", "<cmd>VimtexStop<cr>",    "VimTeX: Stop compilation")
    map("<leader>lc", "<cmd>VimtexClean<cr>",   "VimTeX: Clean build files")

    -- Logs & errors
    map("<leader>le", "<cmd>VimtexErrors<cr>",  "VimTeX: Show errors (quickfix)")
    map("<leader>lo", "<cmd>VimtexCompileOutput<cr>", "VimTeX: Show compiler log")
    map("<leader>lq", "<cmd>copen<cr>",         "Open quickfix")

    -- PDF viewer
    map("<leader>lv", "<cmd>VimtexView<cr>",    "VimTeX: Open PDF viewer")

    -- Misc
    map("<leader>lt", "<cmd>VimtexTocToggle<cr>", "Toggle LaTeX TOC")
    map("<leader>ls", "<cmd>VimtexStatus<cr>",    "VimTeX: Status")
  end,
}
