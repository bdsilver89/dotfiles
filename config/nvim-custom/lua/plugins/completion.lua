return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = { "InsertEnter" },
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
      "onsails/lspkind.nvim",
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
    },
    opts = function()
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local opts = {
        auto_brackets = {},
        completion = {
          completeopt = "menu,menuone,noinsert",
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
        formatting = {
          format = require("lspkind").cmp_format({
            mode = vim.g.enable_icons and "symbol_text" or "text",
            maxwidth = 50,
            ellipsis_char = "...",
            show_labelDetails = true,
          }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
          { name = "snippets" },
          { name = "lazydev" },
        }),
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
        window = {
          completion = {
            scrollbar = false,
            side_padding = 1,
            winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None,FloatBorder:CmpBorder",
            border = "single",
          },
          documentation = {
            border = "single",
            winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
          },
        },
      }

      return opts
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      local cmp = require("cmp")
      cmp.setup(opts)
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = {
      { "hrsh7th/nvim-cmp" },
    },
    opts = {},
    init = function()
      vim.g.enable_autopairs = true
      require("config.utils").toggle("<leader>up", {
        name = "autopairs",
        get = function()
          return vim.g.enable_autopairs
        end,
        set = function(state)
          if state then
            require("nvim-autopairs").enable()
            vim.g.enable_autopairs = true
          else
            require("nvim-autopairs").disable()
            vim.g.enable_autopairs = false
          end
        end,
      })
    end,
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_down", cmp_autopairs.on_confirm_done())
    end,
  },

  {
    "echasnovski/mini.surround",
    recommended = true,
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local mappings = {
        { "gsa", desc = "Add surrounding", mode = { "n", "v" } },
        { "gsd", desc = "Delete surrounding" },
        { "gsf", desc = "Find right surrounding" },
        { "gsF", desc = "Find left surrounding" },
        { "gsh", desc = "Highlight surrounding" },
        { "gsr", desc = "Replace surrounding" },
        { "gsn", desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },

  {
    "danymat/neogen",
    cmd = "Neogen",
    keys = {
      {
        "<leader>cn",
        function()
          require("neogen").generate()
        end,
        desc = "Generate annotations",
      },
    },
    opts = function(_, opts)
      if opts.snippet_engine ~= nil then
        return
      end

      opts.snippet_engine = "nvim"
    end,
  },
}
