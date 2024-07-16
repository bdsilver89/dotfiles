return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    keys = {
      {
        "<tab>",
        function()
          return vim.snippet.active({ direction = 1 }) and "<cmd>lua vim.snippet.jump(1)<cr>" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = { "i", "s" },
      },
      {
        "<s-tab>",
        function()
          return vim.snippet.active({ direction = -1 }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<s-tab>"
        end,
        expr = true,
        silent = true,
        mode = { "i", "s" },
      },
    },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      {
        "garymjr/nvim-snippets",
        opts = {
          friendly_snippets = true,
        },
        dependencies = {
          "rafamadriz/friendly-snippets",
        },
      },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = {
          library = {
            { path = "lazy.nvim", words = { "lazy.nvim" } },
          },
        },
      },
      {
        "Saecki/crates.nvim",
        ft = "toml",
        opts = {
          completion = {
            cmp = { enabled = true },
          },
        },
      },
    },
    config = function()
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      cmp.setup({
        auto_brackets = {},
        completion = {
          completeopt = "menu,menuone,noinsert"
        },
        snippet = {
          expand = function(args)
            return vim.snippet.expand(args.body)
          end,
        },
        preselect = cmp.PreselectMode.Item,
        mapping = cmp.mapping.preset.insert({
          ["<c-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<c-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<c-b>"] = cmp.mapping.scroll_docs(-4),
          ["<c-f>"] = cmp.mapping.scroll_docs(4),
          ["<c-space>"] = cmp.mapping.complete(),
          ["<c-e>"] = cmp.mapping.abort(),
          ["<cr>"] = cmp.mapping.confirm({ select = true }),
          ["<s-cr>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace }),
          ["<c-cr>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
          { name = "snippets" },
          { name = "lazydev" },
          { name = "crates" },
        }),
        -- TODO: formatting?
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      })
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    keys = {
      {
        "<leader>up",
        function()
          local autopairs = require("nvim-autopairs")
          if autopairs.state.disabled then
            autopairs.enable()
            vim.notify("Enabled autopairs", vim.log.levels.INFO, { title = "Option" })
          else
            autopairs.disable()
            vim.notify("Disabled autopairs", vim.log.levels.WARN, { title = "Option" })
          end
        end,
        desc = "Toggle autopairs",
      },
    },
  },
}
