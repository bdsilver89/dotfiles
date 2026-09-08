local languages = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "css",
  "diff",
  "html",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "lua",
  "luadoc",
  "luap",
  "make",
  "markdown_inline",
  "markdown",
  "python",
  "query",
  "regex",
  "rust",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

local installed = require("nvim-treesitter.config").get_installed()
local ts = require("nvim-treesitter")

ts.setup({})

ts.install(vim.iter(languages)
  :filter(function(language)
    return not vim.tbl_contains(installed, language)
  end)
  :totable())

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      vim.cmd("TSUpdate")
    end
  end,
})
