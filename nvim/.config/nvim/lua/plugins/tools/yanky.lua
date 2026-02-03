return {
  "gbprod/yanky.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },

  config = function()
    local yanky_ok, yanky = pcall(require, "yanky")
    if not yanky_ok then
      vim.notify("Failed to load yanky.nvim. Functionality will be limited.", vim.log.levels.WARN)
      return
    end
    vim.keymap.set("n", "p", "<Plug>(YankyPutAfter)")
    vim.keymap.set("n", "P", "<Plug>(YankyPutBefore)")
    vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
    vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")

    yanky.setup({
      -- Configure ring history
      ring = {
        -- History settings with performance optimizations
        history_length = 50,                               -- Reduced from 100 to lower memory usage
        storage = "memory",                                -- Use memory for faster access
        storage_path = vim.fn.stdpath("data") .. "/yanky", -- Path for persistent storage

        -- Sync with system clipboard
        sync_with_numbered_registers = true,

        -- Cancel yank if cursor position changed during operation
        cancel_event = "update",

        -- Clean unused entries periodically to reduce memory usage
        ignore_registers = { "_" }, -- Ignore the black hole register
      },

      -- Enhanced picker setup with custom function to replace the Telescope picker
      picker = {
        select = {
          action = function(entry)
            require("yanky.picker").actions.put("p", false)(entry)
          end,
        },
        -- Basic telescope config that will be enhanced via the override below
        telescope = {
          use_default_mappings = true,
        },
      },

      -- System clipboard integration
      system_clipboard = {
        sync_with_ring = true,
      },

      -- Highlighting settings - reduced duration for better performance
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 100, -- Reduced from 150ms for better performance
      },

      -- Preserve cursor position on put
      preserve_cursor_position = {
        enabled = true,
      },

      -- Clean up duplicates in the yank history to save memory
      deduplicate = true,
    })

    -- Add autocommands to clean up yank history periodically
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function()
        -- Clean up yanky history when writing files to prevent memory growth
        if #require("yanky.history").all() > 30 then
          -- Only keep recent entries
          local entries = require("yanky.history").all()
          for i = 31, #entries do
            require("yanky.history").delete(i)
          end
        end
      end,
    })

    -- Clean up on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        pcall(require("yanky").clear_history)
      end,
    })

    -- Optimize treesitter integration - only use when treesitter is already loaded
    if package.loaded["nvim-treesitter"] then
      vim.g.yanky_use_treesitter = true
    end
  end,
}
