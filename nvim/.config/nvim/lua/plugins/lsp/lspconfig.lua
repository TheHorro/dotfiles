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
      autostart = false,
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

    -- texlab
    lspcfg.texlab = {
      autostart = false,
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
      autostart = false,
      cmd = { "ltex-ls-plus" },
      filetypes = { "bib", "gitcommit", "org", "plaintex", "rst", "rnoweb", "tex", "pandoc", "quarto", "rmd" },
      root_dir = vim.fs.root(0, { ".git", ".ltex", "main.tex" }),
      capabilities = capabilities,
      settings = {
        ltex = {
          language = "de-DE",
          enabled = { "latex", "tex", "bib" },
          -- ltex_ls_plus = {
            --   args = { "--jvm-args", "-Xms128m", "-Xmx512m" }
            -- }
          }
        },
        -- on_attach = on_attach,
        on_init = function (client)
          vim.schedule(function ()
            require("ltex_extra").setup({
              load_langs = { "de-DE" },
              path = vim.fn.getcwd() .. "/.ltex", -- Absolute path ensures it finds it
              server_name = "ltex_plus",
            })
          end)
        end,
        on_attach = function(client, bufnr)
          local ltex_ok, ltex_extra = pcall(require, "ltex_extra")
          if ltex_ok then
            ltex_extra.setup {
              load_langs = { "de-DE" },
              path = vim.fn.getcwd() .. "/.ltex",
            }
          end
        end,
      }

      lspcfg.hyprls = {
        cmd = {'hyprls'},
        filetypes = { "hyprlang" },
        root_markers = { ".git", "hyprland.conf" },
        settings = {
          hyprls = {
            preferIgnoreFile = false,
            ignore = {"hyprlock.conf", "hypridle.conf"}
          }
        }

      }

      lspcfg.pyright = {
        autostart = false,
        cmd = { "pyright-langserver", "--stdio" },
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          python = {
            -- Conda ml-Umgebung fix eingetragen
            pythonPath = vim.fn.expand("~/miniforge3/envs/ml/bin/python"),
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
              -- Damit Pyright die installierten Pakete aus ml findet
              extraPaths = {
                vim.fn.expand("~/miniforge3/envs/ml/lib/python3.12/site-packages"),
              },
            },
          },
        },
      }

      -- ruff (Linter + Formatter, ersetzt flake8/black/isort)
      -- installieren via: yay -S python-ruff (oder: pip install ruff in ml-env)
      lspcfg.ruff = {
        autostart = false,
        cmd = { "ruff", "server" },
        on_attach = function(client, bufnr)
          -- Ruff übernimmt Formatting, Pyright nur Type-Checking
          -- Hover-Infos kommen von Pyright, nicht Ruff
          client.server_capabilities.hoverProvider = false
          on_attach(client, bufnr)
        end,
        capabilities = capabilities,
        init_options = {
          settings = {
            lineLength = 88,
            lint = {
              select = { "E", "F", "I", "UP" },  -- pycodestyle, pyflakes, isort, pyupgrade
            },
          },
        },
      }


      ---------------------------------------------------------------------------
      -- FileType → LSP autostart map
      ---------------------------------------------------------------------------
      local ft_map = {
        lua      = {"lua_ls"},
        python   = {"pyright", "ruff"},
        tex      = {"texlab", "ltex_plus"},
        latex    = {"texlab", "ltex_plus"},
        plaintex = {"texlab", "ltex_plus"},
        markdown = {"texlab"},
        bib      = {"ltex_plus"},
      }

      vim.filetype.add({
        pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
      })

      vim.lsp.enable({ "lua_ls", "pyright", "ruff", "texlab", "ltex_plus", "hyprls" })

      ---------------------------------------------------------------------------
      -- Block stylua from starting as a language server
      ---------------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          if client.name == "stylua" then
            vim.lsp.stop_client(client.id)
            -- elseif client.name == "ltex_plus" then
            -- require("ltex_extra").setup {
              --   load_langs = { "de-DE" },
              --   path = vim.fn.getcwd() .. "/.ltex",
              --   server_name = "ltex_plus",
              -- }
            end
          end,
        })
      end,

      -- vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
      --   pattern = {"*.hl", "hypr*.conf"},
      --   callback = function(event)
      --     print(string.format("starting hyprls for %s", vim.inspect(event)))
      --     vim.lsp.start {
      --       name = "hyprlang",
      --       cmd = {"hyprls"},
      --       root_dir = vim.fn.getcwd(),
      --       settings = {
      --         hyprls = {
      --           preferIgnoreFile = true, -- set to false to prefer `hyprls.ignore`
      --           ignore = {"hyprlock.conf", "hypridle.conf"}
      --         }
      --       }
      --     }
      --   end
      -- })

}
