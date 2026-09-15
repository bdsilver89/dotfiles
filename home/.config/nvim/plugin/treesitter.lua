vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

require("nvim-treesitter").install({
  "bash",
  "c", "cmake", "cpp",
  "gitcommit",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "markdown", "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "tsx", "typescript",
  "vim", "vimdoc",
  "xml",
  "yaml",
})

local group = vim.api.nvim_create_augroup("configts", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    else
      vim.bo[ev.buf].syntax = "on"
    end
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end
    if name == "nvim-treesitter" then
      vim.cmd("TSUpdate")
    end
  end,
})
