local load_textobjects = false

return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo", "TSUpdateSync" },
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      init = function()
        require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter_textojects")
        load_textobjects = true
      end,
    }
  },
  opts = {
    highlight = {
      enable = true,
      additoinal_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
    ensure_installed = {
      -- "c",
      -- "cpp",
      -- "cmake",
      "bash",
      -- "go",
      -- "gomod",
      "html",
      "ini",
      -- "java",
      -- "javascript",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "org",
      "query",
      "regex",
      -- "rust",
      "toml",
      -- "typescript",
      -- "tsx",
      "vim",
      "vimdoc",
      "yaml",
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<c-space>",
        node_incremental = "<c-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
    sync_install = false,
    auto_install = true,
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)

    if load_textobjects then
      if opts.textobjects then
        for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
          if opts.textobjects[mod] and opts.textobjects[mod].enable then
            local Loader = require("lazy.core.loader")
            Loader.disabled_rtp_plugins["nvim-treesitter-textobjects"] = nil
            local plugin = require("lazy.core.config").plugins["nvim-treesitter-textobjects"]
            require("lazy.core.loader").source_runtime(plugin.dir, "plugin")
            break
          end
        end
      end
    end
  end,
}

