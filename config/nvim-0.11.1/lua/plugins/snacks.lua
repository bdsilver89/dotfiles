-- Terminal Mappings
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  keys = function()
    -- stylua: ignore
    local keymaps = {
      -- bufdelete
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },

      -- notifier
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },

      -- git
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },

      -- picker
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader><space>", function() Snacks.picker.files() end, desc = "Files" },
      -- picker find
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      -- picker git
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      -- picker grep
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Open Buffer Lines" },
      -- picker search
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },
      -- picker colorscheme
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },

      -- terminal
      { "<c-/>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "Terminal" },
      { "<c-_>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "which_key_ignore" },
    }

    if vim.fn.executable("lazygit") == 1 then
      keymaps[#keymaps + 1] = {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      }
    end

    return keymaps
  end,
  opts = {
    bigfile = { enabled = true },
    dashboard = {},
    indent = { enabled = true, animate = { enabled = false } },
    input = { enabled = true },
    notifier = { enabled = true },
    terminal = {
      win = {
        keys = {
          nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        },
      },
    },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
    quickfile = { enabled = true },
    words = { enabled = true },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    -- toggle
    -- LazyVim.format.snacks_toggle():map("<leader>uf")
    -- LazyVim.format.snacks_toggle(true):map("<leader>uF")
    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
    Snacks.toggle.diagnostics():map("<leader>ud")
    Snacks.toggle.line_number():map("<leader>ul")
    Snacks.toggle
      .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
      :map("<leader>uc")
    Snacks.toggle
      .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
      :map("<leader>uA")
    Snacks.toggle.treesitter():map("<leader>uT")
    Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
    Snacks.toggle.dim():map("<leader>uD")
    Snacks.toggle.animate():map("<leader>ua")
    Snacks.toggle.indent():map("<leader>ug")
    Snacks.toggle.scroll():map("<leader>uS")
    -- Snacks.toggle.profiler_highlights():map("<leader>dph")

    Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
    Snacks.toggle.zen():map("<leader>uz")

    Snacks.toggle({
      name = "Auto Formating",
      get = function()
        return vim.g.autoformat
      end,
      set = function(state)
        vim.g.autoformat = state
      end,
    }):map("<leader>uf")
  end,
}
