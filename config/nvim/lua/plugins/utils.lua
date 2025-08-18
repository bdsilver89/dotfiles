local add = MiniDeps.add

add("tpope/vim-sleuth")
add("mason-org/mason.nvim")
add("MeanderingProgrammer/render-markdown.nvim")

require("render-markdown").setup({
  code = {
    sign = false,
    width = "block",
    right_pad = 1,
  },
  heading = {
    sign = true,
    icons = {},
  },
})

local ensure_installed = {
  "stylua",
  "lua-language-server",
}

require("mason").setup()
local mr = require("mason-registry")
mr.refresh(function()
  for _, tool in ipairs(ensure_installed) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end)
