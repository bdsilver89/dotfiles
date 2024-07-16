---type table<string, table<integer, table>>
local user_terminals = {}

local function term(opts)
  local terms = user_terminals
  if type(opts) == "string" then
    opts = { cmd = opts }
  end
  opts = vim.tbl_deep_extend("force", { hidden = true }, opts)
  local num = vim.v.count > 0 and vim.v.count or 1
  -- if terminal doesn't exist yet, create it
  if not terms[opts.cmd] then
    terms[opts.cmd] = {}
  end
  if not terms[opts.cmd][num] then
    if not opts.count then
      opts.count = vim.tbl_count(terms) * 100 + num
    end
    local on_exit = opts.on_exit
    opts.on_exit = function(...)
      terms[opts.cmd][num] = nil
      if on_exit then
        on_exit(...)
      end
    end
    terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
  end
  -- toggle the terminal
  terms[opts.cmd][num]:toggle()
end

return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    keys = function()
      local keys = {
        { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggleterm float" },
        { "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Toggleterm horizontal" },
        { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Toggleterm vertical" },
      }

      if vim.fn.executable("lazygit") == 1 then
        -- lazygit viewer
        keys[#keys + 1] = {
          "<leader>gg",
          function()
            term("lazygit")
          end,
          desc = "Toggleterm lazygit",
        }

        -- lazygit line blame
        keys[#keys + 1] = {
          "<leader>gb",
          function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local line = cursor[1]
            local file = vim.api.nvim_buf_get_name(0)
            local cmd = { "git", "log", "-n", "3", "-u", "-L", line .. ",+1:" .. file }
            term(table.concat(cmd, " "))
          end,
          desc = "Toggleterm lazygit blame",
        }

        -- lazygit file
        keys[#keys + 1] = {
          "<leader>gf",
          function()
            local path = vim.api.nvim_buf_get_name(0)
            term("lazygit -f " .. vim.trim(path))
          end,
          desc = "Toggleterm lazygit current file history",
        }

        -- lazygit log
        keys[#keys + 1] = {
          "<leader>gl",
          function()
            term("lazygit log")
          end,
          desc = "Toggleterm lazygit log",
        }
      end
      if vim.fn.executable("node") == 1 then
        keys[#keys + 1] = {
          "<leader>tn",
          function()
            term("node")
          end,
          desc = "Toggleterm node",
        }
      end
      local python = vim.fn.executable("python") == 1 and "python" or vim.fn.executable("python3") == 1 and "python3"
      if python then
        keys[#keys + 1] = {
          "<leader>tp",
          function()
            term(python)
          end,
          desc = "Toggleterm python",
        }
      end
      return keys
    end,
    opts = {
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
        StatusLine = { link = "StatusLine" },
        StatusLineNC = { link = "StatusLineNC" },
        WinBar = { link = "WinBar" },
        WinBarNC = { link = "WinBarNC" },
      },
      size = 10,
      ---@param t Terminal
      on_create = function(t)
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.signcolumn = "no"
        if t.hidden then
          local toggle = function()
            t:toggle()
          end
          vim.keymap.set({ "n", "t", "i" }, "<C-'>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
          vim.keymap.set({ "n", "t", "i" }, "<F7>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
        end
      end,
      shading_factor = 2,
      direction = "float",
      float_opts = { border = "none" },
      -- float_opts = { border = "rounded" },
    },
  },
}
