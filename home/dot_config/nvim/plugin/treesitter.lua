vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

local parsers = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "hcl",
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
  "markdown",
  "markdown_inline",
  "ninja",
  "printf",
  "python",
  "query",
  "regex",
  "ron",
  "rst",
  "ruby",
  "rust",
  "scala",
  "scss",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

vim.schedule(function() require("nvim-treesitter").install(parsers) end)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_treesitterstart", { clear = true }),
  callback = function(ev)
    local ok = pcall(vim.treesitter.start, ev.buf)
    if ok then
      vim.bo[ev.buf].syntax = ""
      vim.bo[ev.buf].indentexpr = function() return require("nvim-treesitter").indentexpr() end
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = function() return vim.treesitter.foldexpr() end
    end
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config_treesitterupdate", { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and (ev.data.kind == "install" or ev.data.kind == "update") then
      require("nvim-treesitter").install(parsers)
      require("nvim-treesitter").update()
    end
  end,
})
