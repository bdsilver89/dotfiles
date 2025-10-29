local M = {}

local modules = require("ui.tabufline.modules")

local function buf_index(bufnr)
  for i, value in ipairs(vim.t.bufs) do
    if value == bufnr then
      return i
    end
  end
end

function M.next()
  local bufs = vim.t.bufs
  local idx = buf_index(vim.api.nvim_get_current_buf())

  if not idx then
    vim.api.nvim_set_current_buf(vim.t.bufs[1])
    return
  end

  vim.api.nvim_set_current_buf((idx == #bufs and bufs[1]) or bufs[idx + 1])
end

function M.prev()
local bufs = vim.t.bufs
  local idx = buf_index(vim.api.nvim_get_current_buf())

  if not idx then
    vim.api.nvim_set_current_buf(vim.t.bufs[1])
    return
  end

  vim.api.nvim_set_current_buf((idx == 1 and bufs[#bufs]) or bufs[idx - 1])
end

function M.close(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].buftype == "terminal" then
    vim.cmd(vim.bo.buflisted and "set nobl | enew" or "hide")
  else
    local idx = buf_index(bufnr)
    local hidden = vim.bo.bufhidden

    if vim.api.nvim_win_get_config(0).zindex then
      vim.cmd("bw")
      return

    elseif idx and #vim.t.bufs > 1 then
      local new_idx = idx == #vim.t.bufs and -1 or 1
      vim.cmd("b" .. vim.t.bufs[idx + new_idx])

    elseif not vim.bo.buflisted then
      local tmp = vim.t.bufs[1]
      if tmp then
        local winid = vim.fn.bufwinid(tmp)
        winid = winid ~= -1 and winid or 0
        vim.api.nvim_set_current_win(winid)
        vim.api.nvim_set_current_buf(tmp)
      end
      vim.cmd("bw" .. bufnr)
      return

    else
      vim.cmd("enew")
    end

    if not (hidden == "delete") then
      vim.cmd("confirm bd" .. bufnr)
    end
  end

  vim.cmd("redrawtabline")
end

function M.close_all(include_current)
  local bufs = vim.t.bufs

  if include_current ~= nil and not include_current then
    table.remove(bufs, buf_index(vim.api.nvim_get_current_buf()))
  end

  for _, buf in ipairs(bufs) do
    M.close(buf)
  end
end

function M.close_direction(x)
  local idx = buf_index(vim.api.nvim_get_current_buf())

  for i, buf in ipairs(vim.t.bufs) do
    if (x == "left" and i < idx) or (x == "right" and i > idx) then
      M.close(buf)
    end
  end
end

function M.move(n)
  local bufs = vim.t.bufs

  for i, buf in ipairs(bufs) do
    if buf == vim.api.nvim_get_current_buf() then
      if  n < 0 and i == 1 or n > 0 and i == #bufs then
        bufs[1], bufs[#bufs] = bufs[#bufs], bufs[1]
      else
        bufs[1], bufs[i + n] = bufs[i + n], bufs[i]
      end

      break
    end
  end

  vim.t.bufs = bufs
  vim.cmd("redrawtabline")
end

function M.goto(bufnr)
  local cur_win = vim.api.nvim_get_current_win()
  local fixedbuf = vim.api.nvim_get_option_value("winfixbuf", { win = cur_win })

  if fixedbuf then
    for _, v in ipairs(vim.api.nvim_list_wins()) do
      local buflisted = vim.api.nvim_get_option_value("buflisted", { buf = vim.api.nvim_win_get_buf(v) })
      local tmp_fixedbuf = vim.api.nvim_get_option_value("winfixbuf", {win = v })

      if buflisted and not tmp_fixedbuf then
        vim.api.nvim_set_current_win(v)
        break
      end
    end
  end

  vim.api.nvim_set_current_buf(bufnr)
end


function M.render()
  local order = { "tree_offset", "buffers", "tabs", "buttons" }
  local result = {}

  for _, v in ipairs(order) do
    local module = modules[v]
    module = type(module) == "string" and module or module()
    table.insert(result, module)
  end

  return table.concat(result)
end

function M.setup()
  vim.t.bufs = vim.t.bufs
    or vim.tbl_filter(function(buf)
      return vim.fn.buflisted(buf) == 1
    end, vim.api.nvim_list_bufs())

  vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter", "TabNew" }, {
    callback = function(event)
      local bufs = vim.t.bufs
      local is_current_buf = vim.api.nvim_get_current_buf() == event.buf

      if bufs == nil then
        bufs = vim.api.nvim_get_current_buf() == event.buf and {} or { event.buf }
      else
        if
          not vim.tbl_contains(bufs, event.buf)
          and (event.event == "BufEnter" or not is_current_buf or vim.api.nvim_get_option_value(
            "buflisted",
            { buf = event.buf }
          ))
          and vim.api.nvim_buf_is_valid(event.buf)
          and vim.api.nvim_get_option_value("buflisted", { buf = event.buf })
        then
          table.insert(bufs, event.buf)
        end
      end

      if event.event == "BufAdd" then
        if
          #vim.api.nvim_buf_get_name(bufs[1]) == 0 and not vim.api.nvim_get_option_value("modified", { buf = bufs[1] })
        then
          table.remove(bufs, 1)
        end
      end

      vim.t.bufs = bufs
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(event)
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local bufs = vim.t[tab].bufs
        if bufs then
          for i, buf in ipairs(bufs) do
            if buf == event.buf then
              table.remove(bufs, i)
              vim.t[tab].bufs = bufs
              break
            end
          end
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufNew", "BufNewFile", "BufRead", "TabEnter", "TermOpen" }, {
    pattern = "*",
    group = vim.api.nvim_create_augroup("TabuflineLazyLoad", {}),
    callback = function()
      if #vim.fn.getbufinfo({ buflisted = 1 }) >= 2 or #vim.api.nvim_list_tabpages() >= 2 then
        vim.o.showtabline = 2
        vim.o.tabline = "%!v:lua.require('ui.tabufline').render()"
        vim.api.nvim_del_augroup_by_name("TabuflineLazyLoad")
      end
    end,
  })
end

return M
