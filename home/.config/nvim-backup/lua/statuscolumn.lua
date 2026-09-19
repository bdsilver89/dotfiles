local M = {}

local sign_hls = {}

local function get_sign_hl(hl)
  local name = "StatusColumn" .. hl
  if not sign_hls[hl] then
    local attrs = vim.api.nvim_get_hl(0, { name = hl, link = false })
    attrs.bg = nil
    attrs.ctermbg = nil
    vim.api.nvim_set_hl(0, name, attrs)
    sign_hls[hl] = true
  end
  return name
end

function M.get_signs()
  local lnum = vim.v.lnum
  local bufnr = vim.api.nvim_get_current_buf()

  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, -1, { lnum - 1, 0 }, { lnum - 1, -1 }, { details = true })

  local left, left_priority = "  ", -1
  local git = "  "

  for _, extmark in ipairs(extmarks) do
    local details = extmark[4]
    if details and details.sign_text then
      local text = details.sign_text
      local hl = details.sign_hl_group
      if hl and hl:find("^GitSigns") then
        git = "%#" .. hl .. "#" .. text .. "%*"
      else
        local priority = details.priority or 0
        if priority > left_priority then
          left = hl and ("%#" .. get_sign_hl(hl) .. "#" .. text .. "%*") or text
          left_priority = priority
        end
      end
    end
  end

  return left, git
end

function M.get_fold()
  local lnum = vim.v.lnum
  local icon = " "

  if vim.v.virtnum == 0 then
    local starts_fold = vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1)
    local foldexpr = vim.wo.foldexpr
    if vim.wo.foldmethod == "expr" and type(foldexpr) == "function" then
      local ok, result = pcall(foldexpr, lnum)
      starts_fold = starts_fold or (ok and tostring(result):sub(1, 1) == ">")
    end

    if vim.fn.foldclosed(lnum) == lnum then
      icon = ""
    elseif starts_fold then
      icon = ""
    end
  end

  return "%#LineNr#" .. icon .. "%*"
end

function M.render()
  local lnum = vim.v.lnum
  local relnum = vim.v.relnum

  local display_num = (vim.wo.relativenumber and relnum > 0) and relnum or lnum
  local number_width = #tostring(vim.api.nvim_buf_line_count(0))
  local number = tostring(display_num) .. string.rep(" ", number_width - #tostring(display_num))

  local left, git = M.get_signs()
  local fold = M.get_fold()

  return left .. fold .. " " .. number .. " " .. git .. " "
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    sign_hls = {}
  end,
})

vim.o.foldcolumn = "0"
vim.o.statuscolumn = "%!v:lua.require'statuscolumn'.render()"

return M
