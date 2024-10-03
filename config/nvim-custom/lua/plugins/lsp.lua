return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      -- {
      --   "j-hui/fidget.nvim",
      --   opts = {
      --     integration = {
      --       ["nvim-tree"] = {
      --         enable = false,
      --       },
      --     },
      --   },
      -- },
      "hrsh7th/cmp-nvim-lsp",
      {
        "williamboman/mason-lspconfig.nvim",
        config = function() end,
      },
    },
    opts = {
      servers = {},
      setup = {},
    },
    config = function(_, opts)
      local Utils = require("config.utils")

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- stylua: ignore start
          -- map("gd", function() require("telescope.builtin").lsp_definitions() end, "Goto definition")
          -- map("gr", function() require("telescope.builtin").lsp_references() end, "Goto references")
          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gr", vim.lsp.buf.references, "List references")
          map("gD", vim.lsp.buf.declaration, "Goto definition")
          map("gi", vim.lsp.buf.implementation, "List implementations")
          map("gi", vim.lsp.buf.implementation, "List implementations")
          map("gy", vim.lsp.buf.type_definition, "Goto type defintion")
          -- map("gG", vim.lsp.buf.workspace_symbol, "Search workspace symbols")
          -- map("gI", function() require("telescope.builtin").lsp_implementations() end, "Goto implementation")
          -- map("gy", function() require("telescope.builtin").lsp_type_definitions() end, "Goto type defintion")
          -- map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("<leader>cl", "<cmd>LspInfo<cr>", "Info")
          -- stylua: ignore end

          map("<leader>cr", function()
            local curr_name = vim.fn.expand("<cword>" .. " ")
            local win = require("plenary.popup").create(curr_name, {
              title = "Rename",
              style = "minimal",
              borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
              relative = "cursor",
              borderhighlight = "RenamerBorder",
              titlehighlight = "RenamerTitle",
              focusable = true,
              width = 25,
              height = 1,
              line = "cursor+2",
              col = "cursor-1",
            })

            vim.cmd("normal A")
            vim.cmd("startinsert")

            vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>q<cr>", { buffer = 0 })

            vim.keymap.set({ "i", "n" }, "<cr>", function()
              local new_name = vim.trim(vim.fn.getline("."))
              vim.api.nvim_win_close(win, true)

              if #new_name > 0 and new_name ~= curr_name then
                local params = vim.lsp.util.make_position_params()
                params.newName = new_name

                vim.lsp.buf_request(0, "textDocument/rename", params)
              end
              vim.cmd.stopinsert()
            end, { buffer = 0 })
          end, "Rename")

          -- NOTE: word highlight, but using vim-illuminate instead...
          if client and client.server_capabilities.documentHighlightProvider then
            local group = vim.api.nvim_create_augroup("config_lsp_highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = buf,
              group = group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = buf,
              group = group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              buffer = buf,
              group = group,
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "config_lsp_highlight", buffer = event2.buf })
              end,
            })
          end

          -- inlay hints
          if client and client.supports_method("textDocument/inlayHint", { bufnr = buf }) then
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
              Utils.toggle("<leader>uh", {
                name = "Inlay hint",
                get = function()
                  return vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
                end,
                set = function(state)
                  vim.lsp.inlay_hint.enable(state, { bufnr = buf })
                end,
              })

              vim.lsp.inlay_hint.enable(true, { bufnr = buf })
            end
          end

          -- codelens
          if client and client.supports_method("textDocument/codeLens", { bufnr = buf }) then
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = buf,
              callback = vim.lsp.codelens.refresh,
            })

            -- TODO: codelens toggle
            map("<leader>cL", vim.lsp.codelens.run, "Codelens run")
          end

          -- signature helper
          if
            client
            and client.server_capabilities.signatureHelpProvider
            and client.server_capabilities.signatureHelpProvider.triggerCharacters
          then
            local signature_group = vim.api.nvim_create_augroup("LspSignature", { clear = false })
            vim.api.nvim_clear_autocmds({ group = signature_group, buffer = buf })
            local trigger_chars = client.server_capabilities.signatureHelpProvider.triggerCharacters or {}

            vim.api.nvim_create_autocmd("TextChangedI", {
              group = signature_group,
              buffer = buf,
              callback = function()
                local cur_line = vim.api.nvim_get_current_line()
                local pos = vim.api.nvim_win_get_cursor(0)[2]
                local prev_char = cur_line:sub(pos - 1, pos - 1)
                local cur_char = cur_line:sub(pos, pos)

                local triggered = false
                for _, char in ipairs(trigger_chars) do
                  if cur_char == char or prev_char == char then
                    triggered = true
                    break
                  end
                end

                if triggered then
                  vim.lsp.buf.signature_help()
                end
              end,
            })
          end
        end,
      })

      local diagnostic_icons = {
        ERROR = vim.g.enable_icons and " " or "E",
        WARN = vim.g.enable_icons and " " or "W",
        HINT = vim.g.enable_icons and " " or "H",
        INFO = vim.g.enable_icons and " " or "I",
      }

      -- diagnostic setup
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = vim.g.enable_icons and "",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = diagnostic_icons.ERROR,
            [vim.diagnostic.severity.WARN] = diagnostic_icons.WARN,
            [vim.diagnostic.severity.HINT] = diagnostic_icons.HINT,
            [vim.diagnostic.severity.INFO] = diagnostic_icons.INFO,
          },
        },
        float = {
          border = "single",
        },
      })

      -- Default border style
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = "rounded"
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      -- Signature helper window
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
        focusable = false,
        silent = true,
        max_height = 7,
      })

      local servers = opts.servers

      local cmp_avail, cmp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_avail and cmp.default_capabilities() or {}
      )

      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mlsp_servers = {}
      if have_mason then
        all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local use_mason = false
      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        end

        -- prevent mason-disabled lspconfig from trying to setup a lsp that is not in the PATH
        local should_setup = true
        if not use_mason and vim.fn.executable(require("lspconfig.configs." .. server).default_config.cmd[1]) == 0 then
          should_setup = false
        end

        if should_setup then
          require("lspconfig")[server].setup(server_opts)
        end
      end

      -- using mason-tool-installer offloads mason-lspconfig setup here
      -- language pack files now set that up separately from lspconfig
      -- when mason is disabled, lspconfig setup is easier to deal with
      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        server_opts = server_opts and (server_opts == true and {} or server_opts) or {}
        if
          server_opts.enabled ~= false
          -- and (vim.g.enable_mason_packages or
          -- and (vim.fn.executable(require("lspconfig")[server].cmd) == 1)
        then
          if server_opts.mason == false or not vim.tbl_contains(all_mlsp_servers, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mason then
        use_mason = true
        mlsp.setup({
          ensure_installed = vim.tbl_deep_extend("force", ensure_installed, {}),
          handlers = { setup },
        })
      end
    end,
  },

  -- {
  --   "RRethy/vim-illuminate",
  --   event = { "BufReadPost", "BufNewFile" },
  --   opts = {
  --     delay = 200,
  --     large_file_cutoff = 2000,
  --     large_file_overrides = {
  --       providers = { "lsp" },
  --     },
  --   },
  --   config = function(_, opts)
  --     require("illuminate").configure(opts)
  --
  --     local function map(key, dir, buffer)
  --       vim.keymap.set("n", key, function()
  --         require("illuminate")["goto_" .. dir .. "_reference"](false)
  --       end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
  --     end
  --
  --     map("]]", "next")
  --     map("[[", "prev")
  --
  --     -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
  --     vim.api.nvim_create_autocmd("FileType", {
  --       callback = function()
  --         local buffer = vim.api.nvim_get_current_buf()
  --         map("]]", "next", buffer)
  --         map("[[", "prev", buffer)
  --       end,
  --     })
  --   end,
  --   keys = {
  --     { "]]", desc = "Next Reference" },
  --     { "[[", desc = "Prev Reference" },
  --   },
  -- },
}
