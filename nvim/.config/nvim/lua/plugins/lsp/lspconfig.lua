return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    ---------------------------------------------------------------------------
    -- NEW API (Neovim 0.11+)
    ---------------------------------------------------------------------------
    local lspcfg = vim.lsp.config      -- NEW native namespace

    ---------------------------------------------------------------------------
    -- Diagnostics
    ---------------------------------------------------------------------------
    local icons = {
      Error = "",
      Warn  = "",
      Hint  = "󰠠",
      Info  = "",
    }
    vim.diagnostic.config({
      virtual_text = false,
      signs = {
        active = true,
        values = {
          { name = "DiagnosticSignError", text = icons.Error },
          { name = "DiagnosticSignWarn",  text = icons.Warn },
          { name = "DiagnosticSignInfo",  text = icons.Info },
          { name = "DiagnosticSignHint",  text = icons.Hint },
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    ---------------------------------------------------------------------------
    -- on_attach
    ---------------------------------------------------------------------------
    local on_attach = function(client, bufnr)
      -- add key maps here if needed
    end

    ---------------------------------------------------------------------------
    -- Capabilities
    ---------------------------------------------------------------------------
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    ---------------------------------------------------------------------------
    -- Server configs (must define vim.lsp.config.<name>)
    ---------------------------------------------------------------------------

    -- lua_ls
    -- installes by AUR: `yay -S lua-language-server` as Mason has version issues of libs bc of Arch
    lspcfg.lua_ls = vim.tbl_deep_extend("force", {
      cmd = { "lua-language-server" },
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = {
            globals = { "vim", "require", "pcall" },
            ignoredPatterns = { "Unused local"},
          },
          workspace = {
            checkThirdParty = false,
            library = {
              vim.fn.expand("$VIMRUNTIME/lua"),
              vim.fn.stdpath("config") .. "/lua",
            },
          },
        },
      },
    }, {
      on_attach = on_attach,
      capabilities = capabilities,
    })

    -- pyright
    lspcfg.pyright = {
      cmd = { "pyright-langserver", "--stdio" },
      on_attach = on_attach,
      capabilities = capabilities,
    }

    -- texlab
    lspcfg.texlab = {
      cmd = { "texlab" },
      settings = {
        texlab = {
          build = { onSave = true },
          chktex = { onEdit = false, onOpenAndSave = false },
          diagnostics = {
            ignoredPatterns = { "Unused label"},
          },
          diagnosticsDelay = 300,
        },
      },
      on_attach = on_attach,
      capabilities = capabilities,
    }

    -- LTeX
    lspcfg.ltex_plus = {
      cmd = { "ltex-ls-plus" },
      settings = {
        ltex = {
          language = "de-DE",
          enabled = { "markdown", "latex", "tex" },
          -- additionalRules = { languageModel = "~/.local/share/ngram/" },
        }
      },
      on_attach = on_attach,
      capabilities = capabilities,
    }

    ---------------------------------------------------------------------------
    -- FileType → LSP autostart map
    ---------------------------------------------------------------------------
    local ft_map = {
      lua      = "lua_ls",
      python   = "pyright",
      tex      = "texlab",
      latex    = "texlab",
      plaintex = "texlab",
      markdown = "ltex_plus",
      bib      = "ltex_plus",
    }

    ---------------------------------------------------------------------------
    -- Block stylua from starting as a language server
    ---------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "stylua" then
          vim.lsp.stop_client(client.id)
        end
      end,
    })

    ---------------------------------------------------------------------------
    -- Autostart LSP with new API (vim.lsp.start)
    ---------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = vim.tbl_keys(ft_map),
      callback = function(ev)
        local server_name = ft_map[ev.match]
        local cfg = lspcfg[server_name]

        if not cfg then
          vim.notify("Missing LSP config: " .. server_name, vim.log.levels.ERROR)
          return
        end

        -- Start server for this buffer if not already attached
        vim.lsp.start(cfg, { bufnr = ev.buf })
      end,
    })
  end,
}
