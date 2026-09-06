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

---@param buf integer
---@param language string
local function try_attach(buf, language)
  if not vim.treesitter.language.add(language) then
    return
  end
  vim.treesitter.start(buf, language)

  vim.bo[buf].syntax = ""
  vim.wo[0][0].foldmethod = "expr"
  vim.wo[0][0].foldexpr = function() return vim.treesitter.foldexpr() end

  if vim.treesitter.query.get(language, "indents") ~= nil then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter.indentexpr()"
    vim.bo[buf].indentexpr = function() return require("nvim-treesitter").indentexpr() end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_treesitterstart", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local filetype = ev.match
    local language = vim.treesitter.language.get_lang(filetype)
    if not language then
      return
    end

    local installed = require("nvim-treesitter").get_installed("parsers")

    if vim.tbl_contains(installed, language) then
      try_attach(buf, language)
    elseif vim.tbl_contains(parsers, language) then
      require("nvim-treesitter").install(parsers):await(function() try_attach(buf, language) end)
    else
      try_attach(ev.buf, language)
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
