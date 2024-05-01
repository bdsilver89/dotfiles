return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "hrsh7th/cmp-buffer", lazy = true },
      { "hrsh7th/cmp-path", lazy = true },
      { "hrsh7th/cmp-nvim-lsp", lazy = true },
      { "saadparwaiz1/cmp_luasnip", lazy = true },
      {
        "L3MON4D3/LuaSnip",
        lazy = true,
        build = vim.fn.has("win32") == 0
            and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil,
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            lazy = true,
          },
        },
        opts = {
          history = true,
          delete_check_events = "TextChanged",
          region_check_events = "CursorMoved",
        },
      },
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      return {
        preselect = cmp.PreselectMode.None,
        formatting = { field = { "kind", "abbr", "menu" } },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp.config.window.bordered({
            col_offset = -2,
            side_padding = 0,
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
        },
        mapping = {
          ["<up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<c-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<c-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<c-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<c-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<c-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<c-a>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<c-space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<c-y>"] = cmp.config.disable,
          ["<c-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
          ["<cr>"] = cmp.mapping.confirm({ select = true }),
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.snippet and vim.snippet.active { direction = 1 } then
              vim.schedule(function() vim.snippet.jump(1) end)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<s-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.snippet and vim.snippet.active { direction = -1 } then
              vim.schedule(function() vim.snippet.jump(-1) end)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = {
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500, group_index = 2 },
          { name = "path", priority = 250 },
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      }
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources or {}) do
        if not source.group_index then source.group_index = 1 end
      end
      require("cmp").setup(opts)
    end,
  },
}
