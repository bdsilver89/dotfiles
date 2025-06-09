local cmake_command
local ctest_command

if vim.fn.executable("cmake3") == 1 then
  cmake_command = "cmake3"
elseif vim.fn.executable("cmake") == 1 then
  cmake_command = "cmake"
else
  return {}
end

if vim.fn.executable("ctest3") == 1 then
  cmake_command = "ctest3"
elseif vim.fn.executable("ctest") == 1 then
  cmake_command = "ctest"
else
  return {}
end

return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "cmake", "make", "ninja" } },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "neocmakelsp", "cmakelint" } },
  },

  {
    "conform.nvim",
    dependencies = {
      "mason.nvim",
      opts = { ensure_installed = { "stylua" } },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
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
      cmake_command = cmake_command,
      ctest_command = ctest_command,
    },
  },
}
