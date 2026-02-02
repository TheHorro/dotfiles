return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-bibtex.nvim",
    "debugloop/telescope-undo.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    "nvim-tree/nvim-web-devicons",
    "gbprod/yanky.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "andrew-george/telescope-themes",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local undo_actions = require("telescope-undo.actions")
    local themes = require("telescope.themes")
    local colors = require("nightfox.palette").load("carbonfox")

    telescope.setup({
      defaults = {
        -- selection_caret = "󰁔 ",
        -- entry_prefix = "  ",
        -- initial_mode = "insert",
        -- selection_strategy = "reset",
        -- sorting_strategy = "ascending",
        -- layout_config = {
        --   horizontal = {
        --     prompt_position = "top",
        --     preview_width = 0.55,
        --   },
        -- },
        path_display = { "truncate " },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<esc>"] = actions.close,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
          },
          n = {
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["K"] = actions.move_to_top,
            ["J"] = actions.move_to_bottom,
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          themes.get_dropdown({
            winblend = 10,
            previewer = false,
          })
        },
        undo = {
          mappings = {
            i = {
              ["<C-a>"] = require("telescope-undo.actions").yank_additions,
              ["<C-d>"] = require("telescope-undo.actions").yank_deletions,
              ["<C-u>"] = require("telescope-undo.actions").restore,
            },
            n = {
              ["y"] = require("telescope-undo.actions").yank_additions,
              ["Y"] = require("telescope-undo.actions").yank_deletions,
              ["u"] = require("telescope-undo.actions").restore,
            },
          },
        },
        bibtex = {
          depth = 1,
          -- Depth for the *.bib file
          global_files = { '~/texmf/bibtex/bib/Zotero.bib' },
          -- Path to global bibliographies (placed outside of the project)
          search_keys = { 'author', 'year', 'title' },
          -- Define the search keys to use in the picker
          citation_format = '{{author}} ({{year}}), {{title}}.',
          -- Template for the formatted citation
          citation_trim_firstname = true,
          -- Only use initials for the authors first name
          citation_max_auth = 2,
          -- Max number of authors to write in the formatted citation
          -- following authors will be replaced by "et al."
          custom_formats = {
            { id = 'citet', cite_maker = '\\citet{%s}' }
          },
          -- Custom format for citation label
          format = 'citet',
          -- Format to use for citation label.
          -- Try to match the filetype by default, or use 'plain'
          context = true,
          -- Context awareness disabled by default
          context_fallback = true,
          -- Fallback to global/directory .bib files if context not found
          -- This setting has no effect if context = false
          wrap = false,
          -- Wrapping in the preview window is disabled by default
        },
      },
    })
    -- Load extensions
    local extensions = { 
      "fzf",
      "yank_history",
      "bibtex",
      "ui-select",
      "themes",
      "undo"
    }
    for _, ext in ipairs(extensions) do
      telescope.load_extension(ext)
    end

    -- Override vim.ui.select for confirmations to use smaller cursor theme
    local original_select = vim.ui.select
    vim.ui.select = function(items, opts, on_choice)
      opts = opts or {}
      -- Use small cursor theme for confirmations
      if opts.kind == "confirmation" or opts.kind == "file_deletion" then
        local theme = opts.kind == "file_deletion" 
          and themes.get_dropdown({ layout_config = { width = 0.25, height = 0.15 }, results_title = "", previewer = false })
          or themes.get_cursor({ layout_config = { width = 0.2, height = 0.15 }, results_title = "", previewer = false })

          require("telescope.pickers").new(theme, {
            prompt_title = opts.prompt or "",
            finder = require("telescope.finders").new_table({
              results = items,
              entry_maker = function(e) return { value = e, display = opts.format_item and opts.format_item(e) or e, ordinal = e } end,
            }),
            sorter = require("telescope.config").values.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                local selection = require("telescope.actions.state").get_selected_entry()
                actions.close(prompt_bufnr)
                if selection and on_choice then on_choice(selection.value) end
              end)
              return true
            end,
          }):find()
        -- local pickers = require("telescope.pickers")
        -- local finders = require("telescope.finders")
        -- local conf = require("telescope.config").values
        -- local actions = require("telescope.actions")
        -- local action_state = require("telescope.actions.state")
        -- local themes = require("telescope.themes")

        -- Use different themes based on the kind
        -- local theme_config
        --
        -- if opts.kind == "file_deletion" then
        --   -- Center the dialog for file deletions (<leader>ak) using dropdown theme
        --   theme_config = themes.get_dropdown({
        --     layout_config = {
        --       width = 0.25,   -- Slightly wider for centered dialog
        --       height = 0.15,  -- 15% of screen height
        --     },
        --     results_title = "",
        --     previewer = false,
        --   })
        -- else
        --   -- Keep cursor position for email deletions and other confirmations
        --   theme_config = themes.get_cursor({
        --     layout_config = {
        --       width = 0.2,   -- 20% of screen width
        --       height = 0.15, -- 15% of screen height  
        --     },
        --     results_title = "",
        --     previewer = false,
        --   })
        -- end
        --
        -- local picker = pickers.new(theme_config, {
        --   prompt_title = opts.prompt or "",
        --   finder = finders.new_table({
        --     results = items,
        --     entry_maker = function(entry)
        --       local display = entry
        --       if opts.format_item then
        --         display = opts.format_item(entry)
        --       end
        --       return {
        --         value = entry,
        --         display = display,
        --         ordinal = entry,
        --       }
        --     end,
        --   }),
        --   sorter = conf.generic_sorter({}),
        --   attach_mappings = function(prompt_bufnr, map)
        --     actions.select_default:replace(function()
        --       local selection = action_state.get_selected_entry()
        --       actions.close(prompt_bufnr)
        --       if selection and on_choice then
        --         on_choice(selection.value)
        --       end
        --     end)
        --     return true
        --   end,
        -- })
        --
        -- picker:find()
      else
        -- Use original (telescope dropdown) for everything else
        original_select(items, opts, on_choice)
      end
    end
    local hi = function(name, val) vim.api.nvim_set_hl(0, name, val) end
    local ts_text = {
      "TelescopeNormal",
      "TelescopeCounter",
      "TelescopePreviewTitle",
      "TelescopeResultsTitle",
      "TelescopePromptNormal",
    }
    local text_hl = { bg = "none", fg = colors.fg1 }
    for _, text in ipairs(ts_text) do
      hi(text, text_hl)
    end
    local ts_groups = {
      "TelescopePromptPrefix",
      "TelescopePromptBorder",
      "TelescopePreviewBorder",
      "TelescopeResultsBorder",
    }
    local groups_hl = { bg = "none", fg = colors.blue.base }
    for _, group in ipairs(ts_groups) do
      hi(group, groups_hl)
    end
    hi("TelescopeBorder", { fg = colors.blue.base, bg = "none" })
    hi("TelescopePromptTitle", { fg = colors.fg1, bg = "none", bold = true })
    hi("TelescopeSelection", { bg = colors.bg3, bold = true })
  end,
}
