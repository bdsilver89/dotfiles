return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "cmake", "make", "ninja" } },
  },

  {
    "mason-tool-installer.nvim",
    opts = { ensure_installed = { "cmakelint" } },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        neocmake = {},
      },
    },
  },

  {
    "nvim-lint",
    opts = {
      formatters_by_ft = {
        cmake = { "cmakelint" },
      },
    },
  },

  {
    "Civitasv/cmake-tools.nvim",
    lazy = true,
    init = function()
      local loaded = false
      local function check()
        local cwd = vim.uv.cwd()
        if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
          require("lazy").load({ plugins = { "cmake-tools.nvim" } })
          loaded = true
        end
      end
      check()
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          if not loaded then
            check()
          end
        end,
      })
    end,
    opts = {
      cmake_executor = {
        name = "overseer",
      },
      cmake_runner = {
        name = "overseer",
      },
    },
  },
}
