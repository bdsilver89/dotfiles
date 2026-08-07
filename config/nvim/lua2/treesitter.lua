local pack = require("pack")

local parsers = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "css",
  "diff",
  "git_config",
  "gitcommit",
  "git_rebase",
  "go",
  "html",
  "java",
  "javascript",
  "json",
  "json5",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

pack.on_plugin_update("nvim-treesitter", function()
  vim.cmd("TSUpdate")
end)

pack.add({
  {
    src = "nvim-treesitter/nvim-treesitter",
    version = "main",
    setup = false,
    on_setup = function()
      vim.schedule(function()
        require("nvim-treesitter").install(parsers)
      end)
    end,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_treesitterfile", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    if not lang then
      return
    end
    if pcall(vim.treesitter.start, ev.buf, lang) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

