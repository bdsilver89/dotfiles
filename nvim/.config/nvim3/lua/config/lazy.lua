local M = {}

---@param path string
function M.bootstrap(path)
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    path
  })
end

function M.setup()
  -- require plugins
  require("lazy").setup({
    spec = {
      { import = "plugins" },
    },
  })

end

function M.post_bootstrap()
  -- close previous lazy window
  vim.api.nvim_buf_delete(0, { force = true })

--  vim.schedule(function()
--    vim.cmd("MasonInstallAll")
--
 --   local packages = " "
 --   require("mason-registry"):on("package:install:success", function(pkg)
 --     packages = string.gsub(packages, pkg.name:gsub("%-", "%%-"), "") -- rm package name
--
 --     if packages:match("%S") == nil then
 --       vim.schedule(function()
  --        vim.api.nvim_buf_delete(0, { force = true })
   --       vim.cmd([[echo '' | redraw]])
  --      end)
  --    end
  --  end)
  --end)
end

return M
