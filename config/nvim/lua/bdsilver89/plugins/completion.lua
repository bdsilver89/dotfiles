return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      {
        "L3MON4D3/LuaSnip",
        -- TODO: disable luasnip for vim.snippets
        -- enabled = function()
        --   return not vim.snippet
        -- end,
        build = vim.fn.has("win32") == 0
          and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil,
        dependencies = {
          "rafamadriz/friendly-snippets",
          "saadparwaiz1/cmp_luasnip",
        },
        keys = {
          {
            "<tab>",
            function()
              return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
            end,
            expr = true,
            silent = true,
            mode = "i"
          },
          {
            "<tab>",
            function()
              require("luasnip").jump(1)
            end,
            mode = "s",
          },
          {
            "<s-tab>",
            function()
              require("luasnip").jump(-1)
            end,
            mode = { "i", "s" },
          },
        },
        opts = {
          history = true,
          delete_check_events = "TextChanged",
        },
        config = function(_, opts)
          require("luasnip").setup(opts)
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
        -- TODO: enable vim.snippets
    -- keys = function()
    --   -- vim native snippet support
    --   if vim.snippet then
    --     return {
    --       {
    --         "<Tab>",
    --         function()
    --           if vim.snippet.jumpable(1) then
    --             vim.schedule(function()
    --               vim.snippet.jump(1)
    --             end)
    --             return
    --           end
    --           return "<Tab>"
    --         end,
    --         expr = true,
    --         silent = true,
    --         mode = "i",
    --       },
    --       {
    --         "<Tab>",
    --         function()
    --           vim.schedule(function()
    --             vim.snippet.jump(1)
    --           end)
    --         end,
    --         silent = true,
    --         mode = "s",
    --       },
    --       {
    --         "<S-Tab>",
    --         function()
    --           if vim.snippet.jumpable(-1) then
    --             vim.schedule(function()
    --               vim.snippet.jump(-1)
    --             end)
    --             return
    --           end
    --           return "<S-Tab>"
    --         end,
    --         expr = true,
    --         silent = true,
    --         mode = { "i", "s" },
    --       }
    --     }
    --   else
    --     return {}
    --   end
    -- end,
    opts = function()
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = 0 })

      local opts = {
        auto_brackets = {},
        completion = {
          compleopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            if vim.snippet then
              vim.snippet.expand(args.body)
            else
              require("luasnip").lsp_expand(args.body)
            end
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = "cmp_lsp" },
          { name = "path" },
          { name = "buffer" },
        }),
        -- TODO: custom icons
        -- formatting = {}
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      }

      if not vim.snippet then
        table.insert(opts.sources, { name = "luasnip" })
      end

      return opts
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end

      local cmp = require("cmp")
      local Kind = cmp.lsp.CompletionItemKind
      cmp.setup(opts)
      cmp.event:on("confirm_done", function(event)
      end)
    end,
  }
}
