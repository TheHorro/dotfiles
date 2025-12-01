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
      virtual_text = true,
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
      -- add keymaps here if needed
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
    lspcfg.lua_ls = vim.tbl_deep_extend("force", {
      cmd = { "lua-language-server" },
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim", "require", "pcall" } },
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
          diagnosticsDelay = 300,
        },
      },
      on_attach = on_attach,
      capabilities = capabilities,
    }

    -- LTeX
    lspcfg.ltex_ls = {
      cmd = {
        "java",
        "-Djdk.xml.totalEntitySizeLimit=0",
        "-jar",
        vim.fn.expand(
          "~/.local/share/nvim/mason/packages/ltex-ls/ltex-ls-16.0.0/lib/ltex-ls-16.0.0.jar"
        ),
      },
      settings = {
        ltex = { language = "en-US" },
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
      markdown = "ltex_ls",
      plaintex = "ltex_ls",
      bib      = "ltex_ls",
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
