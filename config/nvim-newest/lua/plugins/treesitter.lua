return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
    },
    opts = function()
    end,
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    config = function(plugin, opts)
      local ts = require(plugin.main)
    end,
  }
}
