local M = {}

function M.numbercolumn()
  return {
    provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}",
  }
end

function M.setup()
  return {
    M.numbercolumn(),
  }
end

return M
