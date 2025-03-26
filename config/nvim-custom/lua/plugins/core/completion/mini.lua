return {
  {
    "mini.nvim",
    opts = function(_, opts)
      local snippets = require("mini.snippets")
      opts.snippets = {
        snippets = {
          snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),
          snippets.gen_loader.from_lang(),
        },
      }

      opts.completion = {
        window = {
          info = { border = "rounded" },
          signature = { border = "rounded" },
        },
      }
    end,
  },
}
