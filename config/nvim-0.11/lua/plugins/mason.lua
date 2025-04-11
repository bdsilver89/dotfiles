return {
  "williamboman/mason.nvim",
  cmd = "Mason",
  build = ":MasonUpdate",
  keys = {
    { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
  },
  init = function()
    -- need to add mason install dir to path for LSP binaries so mason can be lazy loaded
    local is_windows = vim.fn.has("win32") == 1
    local sep = is_windows and "\\" or "/"
    local delim = is_windows and ";" or ":"
    local mason_path = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep)
    vim.env.PATH = mason_path .. delim .. vim.env.PATH
  end,
  opts = {
    ensure_installed = {
      -- bash
      "bash-language-server",
      "shfmt",

      -- c/cpp
      "codelldb",

      -- cmake
      "cmakelang",
      "cmakelint",
      "neocmakelsp",

      -- go
      "goimports",
      "gofumpt",
      "gopls",

      -- json
      "json-lsp",

      -- lua
      "lua-language-server",
      "stylua",

      -- python
      "ruff",
      "pyright",
      "black",
      -- "debugpy",

      -- typescript
      -- "js-debug-adpater",
      "prettier",
      "vtsls",

      -- yaml
      "yaml-language-server",
    },
    ui = {
      border = "rounded",
    },
  },
  config = function(_, opts)
    require("mason").setup(opts)
    local mr = require("mason-registry")
    mr:on("package:install:success", function()
      vim.defer_fn(function()
        require("lazy.core.handler.event").trigger({
          event = "FileType",
          buf = vim.api.nvim_get_current_buf(),
        })
      end, 100)
    end)

    mr.refresh(function()
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end)
  end,
}
