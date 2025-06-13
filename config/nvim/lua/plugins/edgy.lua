return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>ue",
      function()
        require("edgy").toggle()
      end,
      desc = "Edgy Select Window",
    },
    {
      "<leader>uE",
      function() end,
      desc = "Edgy Select Window",
    },
  },
  opts = function()
    local opts = {
      bottom = {
        {
          ft = "noice",
          size = { height = 0.4 },
          filter = function(buf, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
        "Trouble",
        {
          ft = "qf",
          title = "Quickfix",
        },
        {
          ft = "help",
          size = { height = 20 },
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        {
          ft = "neotest-output-panel",
          title = "Neotest Summry",
          size = { height = 15 },
        },
      },
      left = {
        {
          ft = "neotest-summary",
          title = "Neotest Summary",
        },
      },
      right = {
        {
          ft = "grug-far",
          title = "Grug Far",
          size = { width = 0.4 },
        },
        {
          ft = "OverseerList",
          title = "Overseer",
          open = function()
            require("overseer").open()
          end,
        },
        {
          ft = "copilot-chat",
          title = "Copilot Chat",
          size = { width = 50 },
        },
      },
      keys = {
        ["<c-right>"] = function(win)
          win:resize("width", 2)
        end,
        ["<c-left>"] = function(win)
          win:resize("width", -2)
        end,
        ["<c-up>"] = function(win)
          win:resize("height", 2)
        end,
        ["<c-down>"] = function(win)
          win:resize("height", -2)
        end,
      },
    }

    for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
      opts[pos] = opts[pos] or {}
      table.insert(opts[pos], {
        ft = "snacks_terminal",
        size = { height = 0.4 },
        title = "%{b:snacks_terminal.id}: %{b:term_title}",
        filter = function(_buf, win)
          return vim.w[win].snacks_win
            and vim.w[win].snacks_win.position == pos
            and vim.w[win].snacks_win.relative == "editor"
            and not vim.w[win].trouble_preview
        end,
      })
    end

    return opts
  end,
}
