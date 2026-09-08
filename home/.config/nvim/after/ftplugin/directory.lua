vim.opt_local.bufhidden = "wipe"
vim.keymap.set("n", "q", "<cmd>bd<CR>", { buffer = true, silent = true })

local ns = vim.api.nvim_create_namespace("dir_icons")
local devicons = require("nvim-web-devicons")

vim.api.nvim_create_autocmd("User", {
  pattern = "DirReadPost",
  group = vim.api.nvim_create_augroup("dir_icons", { clear = true }),
  callback = function(ev)
    vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)
    for i, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)) do
      local icon, hl = " ", "Directory"
      if line:sub(-1) ~= "/" then
        icon, hl = devicons.get_icon(line, nil, { default = true })
      end
      vim.api.nvim_buf_set_extmark(ev.buf, ns, i - 1, 0, {
        virt_text = { { icon .. " ", hl } },
        virt_text_pos = "inline",
      })
    end
  end,
})
