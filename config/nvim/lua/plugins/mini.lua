return {
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      -- text objects
      require("mini.ai").setup({ n_lines = 500 })

      -- surround edits
      require("mini.surround").setup()

      -- comment
      require("mini.comment").setup()

      -- indentscope
      require("mini.indentscope").setup({
        symbol = "│",
        options = { try_as_border = true },
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "terminal",
          "Trouble",
          "trouble",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })

      -- TODO: mini.session?

      -- basic statusline
      -- local statusline = require("mini.statusline")
      -- statusline.setup({ use_icons = vim.g.enable_icons })

      -- bufremove
      local bufremove = require("mini.bufremove")
      bufremove.setup()
      vim.keymap.set(
        "n",
        "<leader>bd",
        function()
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then
              vim.cmd.write()
              bufremove.delete(0)
            elseif choice == 2 then
              bufremove.delete(0, true)
            end
          else
            bufremove.delete(0)
          end
        end,
        { desc = "Delete buffer" })

      vim.keymap.set(
        "n",
        "<leader>bd",
        function()
          bufremove.delete(0, true)
        end,
        { desc = "Delete buffer (force)" })
    end,
  },
}
