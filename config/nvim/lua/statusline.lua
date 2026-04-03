local M = {}

function M.render()
  return table.concat({
    "%<%f %h%w%m%r",
    " %{% v:lua.require('vim._core.util').term_exitcode() %}",
    " %{% exists('b:gitsigns_head') ? ' '..b:gitsigns_head : '' %}",
    "%{% exists('b:gitsigns_status') && b:gitsigns_status != '' ? ' '..b:gitsigns_status : '' %}",
    "%=",
    "%{% luaeval('(package.loaded[''vim.lsp''] and vim.lsp.status()) or '''' ')%} ",
    "%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}",
    "%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}",
    "%{% &busy > 0 ? '◐ ' : '' %}",
    "%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}",
    "%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}",
  })
end

vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
