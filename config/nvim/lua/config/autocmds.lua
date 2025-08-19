local augroup = function(name)
  return vim.api.nvim_create_augroup("bdsilver89/" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = augroup("yank_highlight"),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reload",
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  desc = "Resize splits",
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd=")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Terminal settings",
  group = augroup("terminal_settings"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Close with <q>",
  group = augroup("close_with_q"),
  pattern = {
    "Avante",
    "codecompanion",
    "checkhealth",
    "gitsigns-blame",
    "grug-far",
    "help",
    "man",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "qf",
    "query",
  },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", function()
      vim.cmd("close")
      pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
    end, { buffer = args.buf, silent = true, desc = "Quit Buffer" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Wrap and spellcheck filetypes",
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Auto create dirs when saving file",
  group = augroup("auto_create_dirs"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP settings",
  group = augroup("lspattach"),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
    --   vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    -- end

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc, buffer = ev.buf })
    end

    map("gd", vim.lsp.buf.definition, "vim.lsp.buf.definition")
    map("gD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration")
    map("gW", vim.lsp.buf.workspace_symbol, "vim.lsp.buf.workspace_symbol")

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, ev.buf) then
      local hl_augroup = augroup("lsphighlight")

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = ev.buf,
        group = hl_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = ev.buf,
        group = hl_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = augroup("lsphighlightdetach"),
        callback = function(ev2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "bdsilver89/lsphighlight", buffer = ev2.buf })
        end,
      })
    end
  end,
})
