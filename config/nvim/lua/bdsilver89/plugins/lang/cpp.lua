local M = {}

function M.lsp_dependencies()
  return {
    {
      "p00f/clangd_extensions.nvim",
      lazy = true,
      opts = {
        inlay_hints = {
          inline = false,
        },
        -- TODO: add specific nerd icons symbols for clang AST
        -- ast = { },
      },
      config = function()
      end,
    },
  }
end

function M.lsp_config()
  return {
    clangd = {
      root_dir = function(fname)
        return require("lspconfig.util").root_pattern(
          "Makefile",
          "configure.ac",
          "configure.in",
          "config.h.in",
          "meson.build",
          "meson_options.txt",
          "build.ninja"
        )(fname)
          or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname)
          or require("lspconfig.util").find_git_ancestor(fname)
      end,
      capabilities = {
        offsetEncodin= { "utf-16" },
      },
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      },
      init_options = {
        usePlaceholders = true,
        completionUnimported = true,
        clangdFileStatus = true,
      },
    },
  }
end

return M
