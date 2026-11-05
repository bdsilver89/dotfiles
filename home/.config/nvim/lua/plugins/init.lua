local gh = function(x)
  return "https://github.com/" .. x
end

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config_packchanged", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end
    if name == "telescope-fzf-native.nvim" then
      if not ev.data.active then
        vim.cmd.packadd("telescope-fzf-native.nvim")
      end
      local result = vim.system({ "make" }, { cwd = ev.data.path, text = true }):wait()
      if result.code ~= 0 then
        error("Failed to build telescope-fzf-native.nvim: " .. (result.stderr or result.stdout or ""))
      end
    elseif name == "nvim-treesitter" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      require("nvim-treesitter").update()
    end
  end,
})

vim.pack.add({
  -- UI
  { src = gh("projekt0n/github-nvim-theme") },
  { src = gh("nvim-lualine/lualine.nvim") },

  -- Editor
  { src = gh("nvim-treesitter/nvim-treesitter") },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects") },
  { src = gh("saghen/blink.cmp"), version = vim.version.range("*") },
  { src = gh("L3MON4D3/LuaSnip") },
  { src = gh("rafamadriz/friendly-snippets") },
  { src = gh("stevearc/conform.nvim") },
  { src = gh("mfussenegger/nvim-lint") },

  -- Debugging
  { src = gh("mfussenegger/nvim-dap") },
  { src = gh("igorlfs/nvim-dap-view") },
  { src = gh("theHamsta/nvim-dap-virtual-text") },

  -- Telescope
  { src = gh("nvim-lua/plenary.nvim") },
  { src = gh("nvim-telescope/telescope.nvim") },
  { src = gh("nvim-telescope/telescope-fzf-native.nvim") },
  { src = gh("nvim-telescope/telescope-ui-select.nvim") },
  { src = gh("nvim-telescope/telescope-frecency.nvim") },

  -- Util
  { src = gh("nvim-mini/mini.nvim") },
  { src = gh("lewis6991/gitsigns.nvim") },
  { src = gh("tpope/vim-sleuth") },
  { src = gh("tpope/vim-fugitive") },
  { src = gh("christoomey/vim-tmux-navigator") },
  { src = gh("meanderingprogrammer/render-markdown.nvim") },
  { src = gh("b0o/SchemaStore.nvim") },
})

vim.pack.add({
  { src = gh("saecki/crates.nvim") },
}, { load = false })

vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")

require("plugins.colorscheme")
require("plugins.lualine")
require("plugins.treesitter")
require("plugins.completions")
require("plugins.formatting")
require("plugins.linting")
require("plugins.debugging")
require("plugins.telescope")
require("plugins.mini")
require("plugins.git")
require("plugins.rust")
require("plugins.lsp")
