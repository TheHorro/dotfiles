-- Helper to detect specific LaTeX contexts (citations, refs, etc.)
local function is_latex_special_context()
  if vim.bo.filetype ~= 'tex' then return false end
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(1, col)
  
  -- Patterns for references and citations
  local patterns = {
    '\\cite[%w]*{[^}]*$', '\\[Cc]ref{[^}]*$', '\\ref{[^}]*$', 
    '\\eqref{[^}]*$', '\\autoref{[^}]*$', '\\citet?[%w]*{[^}]*$'
  }
  for _, p in ipairs(patterns) do
    if before:match(p) then return true end
  end
  return false
end

return {
  {
    "saghen/blink.compat",
    version = "*",
    lazy = true,
    opts = { impersonate_nvim_cmp = true },
  },
  {
    "saghen/blink.cmp",
    version = "*", -- Use latest stable
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "saghen/blink.compat",
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      {
        "micangl/cmp-vimtex",
        -- No need for manual setup here, we can pass it to compat
      },
    },
    opts = {
      snippets = { preset = 'luasnip' },
      
      keymap = {
        preset = 'default',
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'snippet_forward', 'select_and_accept', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
      },

      appearance = {
        -- Only define what you want to change; others fall back to defaults
        kind_icons = {
          Text = "󰦨", Method = "󰆧", Function = "󰊕", Field = "󰇽",
          Variable = "󰂡", Class = "󰠱", Property = "󰜢", Value = "󰎠",
          Keyword = "󰌋", Color = "󰏘", File = "󰈙", Folder = "󰉋",
          Constant = "󰀫", Operator = "󰘧", TypeParameter = "󰅲",
        }
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        -- Added 'vimtex' via compat for better bibtex support
        per_filetype = {
          tex = { 'snippets', 'vimtex', 'lsp', 'path', 'buffer' },
        },
        providers = {
          -- Use blink.compat to bring in the specialized vimtex source
          vimtex = {
            name = 'vimtex',
            module = 'blink.compat.source',
            score_offset = 100, -- Give it priority over general LSP
          },
          lsp = {
            enabled = function() return not is_latex_special_context() end,
          },
          path = {
            enabled = function() return not is_latex_special_context() end,
          },
          buffer = {
            enabled = function() return not is_latex_special_context() end,
            max_items = 8,
            min_keyword_length = 2,
            opts = {
              max_async_buffer_size = 500000,
              max_total_buffer_size = 1000000,
              use_cache = true,
            },
          },
        },
      },

      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
            blocked_filetypes = { 'tex', 'latex', 'markdown' }
          }
        },
        menu = {
          draw = {
            columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = { enabled = false },
      },
    },
  },
}
