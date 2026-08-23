local M = {}

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
          left = hl and ("%#" .. hl .. "#" .. text .. "%*") or text
          left_priority = priority
        end
      end
    end
  end

  return left, git
end

function M.render()
  local lnum = vim.v.lnum
  local relnum = vim.v.relnum

  local display_num = (vim.wo.relativenumber and relnum > 0) and relnum or lnum

  local left, git = M.get_signs()

  return left .. "%=" .. display_num .. " " .. git .. " "
end

vim.o.statuscolumn = "%!v:lua.require'statuscolumn'.render()"

return M
