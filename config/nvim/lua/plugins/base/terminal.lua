local terms = {}

function toggle_term(opts)
  if type(opts) == "string" then
    opts = { cmd = opts, hidden = true }
  end
  local num = vim.v.count > 0 and vim.v.count or 1
  if not terms[opts.cmd] then
    terms[opts.cmd] = {}
  end
  if not terms[opts.cmd][num] then
    if not opts.count then
      opts.count = vim.tbl_count(terms) * 100 + num
    end
    if not opts.on_exit then
      opts.on_exit = function()
        terms[opts.cmd][num] = nil
      end
    end
    terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
  end
  terms[opts.cmd][num]:toggle()
end

return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      {
        "<leader>gg",
        function()
          if vim.fn.executable("lazygit") == 1 then
            toggle_term("lazygit")
          end
        end,
        desc = "Toggle lazygit",
      },
    },
    opts = {
      highlights = {},
      size = 10,
      on_create = function()
        vim.opt.foldcolumn = "0"
        vim.opt.signcolumn = "no"
      end,
      open_mapping = "[[<F7>]]",
      shading_factor = 2,
      direction = "float",
      float_opts = { border = "rounded" },
    },
  },
}
