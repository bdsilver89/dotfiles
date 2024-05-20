-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.color.headlines-nvim" },

  -- { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.rose-pine" },

  { import = "astrocommunity.file-explorer.oil-nvim" },

  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.git.neogit" },

  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.lua" },
}
