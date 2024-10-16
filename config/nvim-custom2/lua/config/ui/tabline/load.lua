vim.t.bufs = vim.t.bufs or vim.api.nvim_list_bufs()

local listed_bufs = {}
for _, val in ipairs(vim.t.bufs) do
  if vim.bo[val].buflisted then
    table.insert(listed_bufs, val)
  end
end
vim.t.bufs = listed_bufs

vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter", "tabnew" }, {
  callback = function(args)
    local bufs = vim.t.bufs
    local is_curbuf = vim.api.nvim_get_current_buf() == args.buf

    if bufs == nil then
      bufs = is_curbuf and {} or { args.buf }
    else
      if
        not vim.tbl_contains(bufs, args.buf)
        and (args.event == "BufEnter" or not is_curbuf or vim.api.nvim_get_option_value("buflisted", { buf = args.buf }))
        and vim.api.nvim_buf_is_valid(args.buf)
        and vim.api.nvim_get_option_value("buflisted", { buf = args.buf })
      then
        table.insert(bufs, args.buf)
      end
    end

    if args.event == "BufAdd" then
      if
        #vim.api.nvim_buf_get_name(bufs[1]) == 0 and not vim.api.nvim_get_option_value("modified", { buf = bufs[1] })
      then
        table.remove(bufs, 1)
      end
    end

    vim.t.bufs = bufs

    if args.event == "BufEnter" then
      local buf_history = vim.g.buf_history or {}
      table.insert(buf_history, args.buf)
      vim.g.buf_history = buf_history
    end
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
      local bufs = vim.t[tab].bufs
      if bufs then
        for i, bufnr in ipairs(bufs) do
          if bufnr == args.buf then
            table.remove(bufs, i)
            vim.t[tab].bufs = bufs
            break
          end
        end
      end
    end
  end,
})

if vim.g.tabline_lazyload then
  vim.api.nvim_create_autocmd({ "BufNew", "BufNewFile", "BufRead", "TabEnter", "TermOpen" }, {
    pattern = "*",
    group = vim.api.nvim_create_augroup("config_tablinelazyload", {}),
    callback = function()
      if #vim.fn.getbufinfo({ buflisted = 1 }) >= 2 or #vim.api.nvim_list_tabpages() >= 2 then
        vim.opt.showtabline = 2
        vim.opt.tabline = "%!v:lua.require('config.ui.tabline.modules')()"
        vim.api.nvim_del_augroup_by_name("config_tablinelazyload")
      end
    end,
  })
else
  vim.opt.showtabline = 2
  vim.opt.tabline = "%!v:lua.require('config.ui.tabline.modules')()"
end
