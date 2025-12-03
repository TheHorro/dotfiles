return {
  "dense-analysis/ale",
  event = "BufReadPre",
  config = function()
    vim.g.ale_linters_explicit = 1
    vim.g.ale_fix_on_save = 0
    vim.g.ale_fixers = {
      ['*'] = {'remove_trailing_lines', 'trim_whitespace'}
    }

    vim.g.ale_linters = {
      markdown = {'vale'},
      text = {'vale'},
      rst = {'vale'},
      tex = {'vale'}
    }

    vim.api.nvim_set_keymap('n', '[e', '<Plug>(ale_previous_wrap)', {})
    vim.api.nvim_set_keymap('n', ']e', '<Plug>(ale_next_wrap)', {})

    vim.api.nvim_set_keymap('n', '<leader>Tf', ':ALEFix<CR>', {})
    -- Enable built-in spell checking for English and German
    vim.o.spell = true
    vim.o.spelllang = 'en_us,de'
    ------------------------------------------------------------
    -- Optional: Automatic language detection for spell
    ------------------------------------------------------------
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = {"*.md","*.txt","*.rst","*.tex"},
      callback = function()
        local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
        -- Simple detection: if contains "ß" or "ü", enable German first
        if first_line:match("[ßüöä]") then
          vim.o.spelllang = 'de,en_us'
        else
          vim.o.spelllang = 'en_us,de'
        end
      end
    })
  end
}
