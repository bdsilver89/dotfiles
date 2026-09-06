local M = {}

function M.render()
  local sections = {
    -- truncation point + relative filename
    "%<%f",
    -- help/preview/modified/readonly flags + terminal exit code
    "%( %h%w%m%r%{ v:lua.require('vim._core.util').term_exitcode() }%)",
    -- git branch (gitsigns)
    "%{ get(b:, 'gitsigns_head', '') != '' ? '  ' . b:gitsigns_head : '' }",
    -- git hunk counts for this file (gitsigns): +added ~changed -removed
    "%{ get(b:, 'gitsigns_status', '') != '' ? '  ' . b:gitsigns_status : '' }",
    -- right-align everything after this
    "%=",
    -- pending command / selection size
    " %(%-10S %)",
    -- busy spinner
    "%{ &busy > 0 ? '◐ ' : '' }",
    -- vim.ui progress (current window only)
    "%(%{ luaeval('(package.loaded[''vim.ui''] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) and vim.ui.progress_status()) or '''' ')} %)",
    -- diagnostic counts
    "%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count(0)) and vim.diagnostic.status() .. '' '') or '''' ') %}",
    -- keymap (e.g. langmap indicator)
    "%(%k %)",
    -- ruler
    "%{% &ruler ? &rulerformat : '' %}",
  }

  return table.concat(sections)
end

_G.Statusline = M
vim.o.statusline = "%!v:lua.Statusline.render()"
