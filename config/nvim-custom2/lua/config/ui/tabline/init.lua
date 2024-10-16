local M = {}

local function buf_index(bufnr)
  for i, val in ipairs(vim.t.bufs) do
    if val == bufnr then
      return i
    end
  end
end

function M.next()
  local bufs = vim.t.bufs
  local curbuf_index = buf_index(vim.api.nvim_get_current_buf())

  if not curbuf_index then
    vim.api.nvim_set_current_buf(vim.t.bufs[1])
  else
    vim.api.nvim_set_current_buf((curbuf_index == #bufs and bufs[1]) or bufs[curbuf_index + 1])
  end
end

function M.prev()
  local bufs = vim.t.bufs
  local curbuf_index = buf_index(vim.api.nvim_get_current_buf())

  if not curbuf_index then
    vim.api.nvim_set_current_buf(vim.t.bufs[1])
    return
  end

  vim.api.nvim_set_current_buf((curbuf_index == 1 and bufs[#bufs]) or bufs[curbuf_index - 1])
end

function M.close_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].buftype == "terminal" then
    vim.cmd(vim.bo.buflisted and "set nobl | enew" or "hide")
  else
    local curbuf_index = buf_index(bufnr)
    local bufhidden = vim.bo.bufhidden

    if (not vim.bo[bufnr].buflisted) or vim.api.nvim_win_get_config(0).zindex then
      vim.cmd("bw")
      return
    elseif curbuf_index and #vim.t.bufs > 1 then
      local newbuf_index = curbuf_index == #vim.t.bufs and -1 or 1
      vim.cmd("b" .. vim.t.bufs[curbuf_index + newbuf_index])
    elseif not vim.bo.buflisted then
      local tmpbufnr = vim.t.bufs[1]

      -- TODO: this is used by dash+cheatsheet, is it needed here?
      if vim.g.prev_buf and vim.api.nvim_buf_is_valid(vim.g.prev_buf) then
        tmpbufnr = vim.g.prev_buf
      end

      vim.cmd("b" .. tmpbufnr .. " | bw" .. bufnr)
      return
    else
      vim.cmd("enew")
    end

    if not (bufhidden == "delete") then
      vim.cmd("confirm bd" .. bufnr)
    end
  end

  vim.cmd("redrawtabline")
end

function M.close_all_bufs(include_cur_buf)
  local bufs = vim.t.bufs

  if not include_cur_buf then
    table.remove(bufs, buf_index(vim.api.nvim_get_current_buf()))
  end

  for _, buf in ipairs(bufs) do
    M.close_buffer(buf)
  end
end

function M.close_bufs_direction(x)
  local bufi = buf_index(vim.api.nvim_get_current_buf())

  for i, bufnr in ipairs(vim.t.bufs) do
    if (x == "left" and i < bufi) or (x == "right" and i > bufi) then
      M.close_buffer(bufnr)
    end
  end
end

function M.move_buf(n)
  local bufs = vim.t.bufs

  for i, bufnr in ipairs(bufs) do
    if bufnr == vim.api.nvim_get_current_buf() then
      if n < 0 and i == 1 or n > 0 and i == #bufs then
        bufs[1], bufs[#bufs] = bufs[#bufs], bufs[1]
      else
        bufs[i], bufs[i + n] = bufs[i + n], bufs[i]
      end

      break
    end
  end

  vim.t.bufs = bufs
  vim.cmd("redrawtabline")
end

return M
