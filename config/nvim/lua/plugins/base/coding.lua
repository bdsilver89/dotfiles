return {
  {
    "L3MON4D3/Luasnip",
    build = vim.fn.has("win32") == 0
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
      or nil,
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    -- stylua: ignore
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
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
      region_check_events = "CursorMoved",
    },
    config = function(_, opts)
      require("luasnip").config.setup(opts)
      vim.tbl_map(function(type)
        require("luasnip.loaders.from_" .. type).lazy_load()
      end, { "vscode", "snipmate", "lua" })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      local luasnip_avail, luasnip = pcall(require, "luasnip")
      -- local lspkind_avail, lspkind = pcall(require, "lspkind")

      local border_opts = {
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      }

      return {
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(_, item)
            local Icons = require("utils.icons")
            if Icons.kinds[item.kind] then
              item.kind = Icons.kinds[item.kind] .. item.kind
            end
            return item
          end,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(border_opts),
          documentation = cmp.config.window.bordered(border_opts),
        },
        mapping = {
          ["<c-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<c-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<c-b>"] = cmp.mapping.scroll_docs(-4),
          ["<c-f>"] = cmp.mapping.scroll_docs(4),
          ["<c-space>"] = cmp.mapping.complete(),
          ["<c-e>"] = cmp.mapping.abort(),
          ["<cr>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        sorting = defaults.sorting,
      }
    end,
  },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = function()
      local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
    end,
  },
  -- {
  --   "ThePrimeagen/refactoring.nvim",
  --   keys = {
  --     {
  --       "<leader>re",
  --       function()
  --         require("telescope").extensions.refactoring.refactors()
  --       end,
  --       desc = "Refactoring",
  --       mode = { "x", "v", "n" },
  --     },
  --     {
  --       "<leader>rd",
  --       function()
  --         require("refactoring").debug.printf({ below = false })
  --       end,
  --       desc = "Insert debug print statement",
  --     },
  --     {
  --       "<leader>rv",
  --       {
  --         n = function()
  --           require("refactoring").debug.print_var({ normal = true })
  --         end,
  --         x = function()
  --           require("refactoring").debug.print_var({})
  --         end,
  --       },
  --       desc = "Insert print var debug statement",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<leader>rc",
  --       function()
  --         require("refactoring").debug.cleanup()
  --       end,
  --       desc = "Clean up debug statements",
  --     },
  --   },
  -- },
  {
    "danymat/neogen",
    opts = {
      enabled = true,
      snippet_engine = "luasnip",
      languages = {
        lua = {
          template = {
            annoation_convention = "ldoc",
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>cgd", function() require("neogen").generate() end,                   desc = "Annotation" },
      { "<leader>cgc", function() require("neogen").generate({ type = "class" }) end, desc = "Class" },
      { "<leader>cgf", function() require("neogen").generate({ type = "func" }) end,  desc = "Function" },
      { "<leader>cgt", function() require("neogen").generate({ type = "type" }) end,  desc = "Type" },
    },
  },
}
