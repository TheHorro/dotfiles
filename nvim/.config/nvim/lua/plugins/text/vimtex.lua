return {
  "lervag/vimtex",
  init = function()
    -- Indentation settings
    vim.g.vimtex_indent_enabled = false            -- Disable auto-indent from Vimtex
    vim.g.tex_indent_items = false                 -- Disable indent for enumerate
    vim.g.tex_indent_brace = false                 -- Disable brace indent

    -- Compiler settings
    --- Explicit compiler backend selection
    vim.g.vimtex_compiler_method = 'latexmk'
    -- latexmk configuration
    vim.g.vimtex_compiler_latexmk = {
      backend = "nvim",
      background = 1,
      build_dir = "out",
      out_dir = "out",
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      -- hooks = {},
      options = {
        '-xelatex',                                -- Use XeLaTeX engine
        '-interaction=nonstopmode',                -- Don't stop on errors
        '-file-line-error',                        -- Better error messages
        '-synctex=1',                              -- Enable SyncTeX
        '-shell-escape', -- Often needed for minted or tikz packages
        -- '-verbose',
        '-outdir=out'
      },
    }

    vim.g.vimtex_compiler_search_path = {
      '.',
      '..',
    }

    -- Viewer Settings
    vim.g.vimtex_view_method = 'zathura'            -- Sioyek PDF viewer for academic documents
    -- Note: Not setting vimtex_view_sioyek_options allows VimTeX to handle window management
    -- It will open new windows when needed but reuse for the same document
    vim.g.vimtex_context_pdf_viewer = 'okular'     -- External PDF viewer for the Vimtex menu
    vim.g.vimtex_view_use_temp_files = 0 -- Prevents some viewer lock issues

    -- Formatting settings
    -- vim.g.vimtex_format_enabled = true             -- Enable formatting with latexindent
    -- vim.g.vimtex_format_program = 'latexindent'

    -- Quickfix settings
    vim.g.vimtex_quickfix_mode = 2
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
    -- TOC settings for better navigation
    vim.g.vimtex_toc_config = {
      name = 'TOC',
      layers = { 'content', 'todo', 'include' },
      split_width = 30,
      todo_sorted = 0,
      show_help = 0,
      show_numbers = 1,
    }
  end,

  config = function()
    -- vim.api.nvim_create_autocmd("BufWritePost", {
    --   pattern = "*.tex",
    --   callback = function()
    --     -- This triggers a single-shot compilation every time you save (:w)
    --     vim.cmd("VimtexCompileSS") 
    --   end,
    -- })

    -- Keymaps
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true, buffer = true })
    end

    -- Use autocmd to set keybinds only for TeX files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function()
        map("<leader>ll", "<cmd>VimtexCompile<cr>", "Compile")
        map("<leader>lk", "<cmd>VimtexStop<cr>", "Stop")
        map("<leader>lc", "<cmd>VimtexClean<cr>", "Clean")
        map("<leader>lv", "<cmd>VimtexView<cr>", "View PDF")
        map("<leader>le", "<cmd>VimtexErrors<cr>", "Errors")
        map("<leader>lt", "<cmd>VimtexTocToggle<cr>", "TOC")
        map("<leader>lx", "<cmd>VimtexContextMenu<cr>", "Context Menu")

        -- Text Objects: often overlooked but very powerful
        -- Use 'ie' for inside environment, 'ae' for around environment
      end,
    })
  end,
}
