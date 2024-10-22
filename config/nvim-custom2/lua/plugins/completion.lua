return {
  {
    "hrsh7th/nvim-cmp",
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
        "Saecki/crates.nvim",
        ft = "toml",
        opts = {
          completion = {
            cmp = {
              enabled = true,
            },
          },
        },
      },
    },
    opts = function()
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      return {
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
          format = function(entry, item)
            local icons = require("config.ui.icons.lspkind")

            item.menu = item.kind
            item.menu_hl_group = "CmpItemKind" .. (item.kind or "")

            if vim.g.enable_icons and icons.kind and icons[item.kind] then
              item.kind = item.kind and icons[item.kind] .. " " or ""
            end

            local entry_item = entry:get_completion_item()
            local color = entry_item.documentation

            -- colorify completion formatting
            if color and type(color) == "string" and color:match("^#%x%x%x%x%x%x$") then
              local hl = "hex-" .. color:sub(2)

              if #vim.api.nvim_get_hl(0, { name = hl }) == 0 then
                vim.api.nvim_set_hl(0, hl, { fg = color })
              end

              item.kind = "󱓻"
              item.kind_hl_group = hl
              item.menu_hl_group = hl
            end

            return item
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
          { name = "snippets" },
          { name = "crates" },
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

      vim.keymap.set("n", "<leader>up", function()
        local state = not vim.g.enable_autopairs
        if state then
          require("nvim-autopairs").enable()
          vim.g.enable_autopairs = true
          vim.notify("Enabled autopairs", vim.log.levels.INFO, { title = "Autopairs" })
        else
          require("nvim-autopairs").disable()
          vim.g.enable_autopairs = false
          vim.notify("Disabled autopairs", vim.log.levels.WARN, { title = "Autopairs" })
        end
      end, { desc = "Toggle autopairs" })
    end,
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_down", cmp_autopairs.on_confirm_done())
    end,
  },
}
