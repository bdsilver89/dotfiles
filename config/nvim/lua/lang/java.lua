if vim.fn.executable("java") == 0 then
  return {}
end

return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "jdtls" } },
  },

  {
    "nvim-dap",
    dependencies = {
      "mason.nvim",
      opts = { ensure_installed = { "java-debug-adapter", "java-test" } },
    },
    opts = function()
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
    end,
  },

  -- {
  --   "mfussenegger/nvim-jdtls",
  --   ft = "java",
  --   opts = function()
  --     return {}
  --   end,
  -- },
}
