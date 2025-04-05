local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Hightlight when yanking text",
  group = augroup("highlightyank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check for file reaload",
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
  group = augroup("termopen"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Close filetypes with <q>",
  group = augroup("close_with_q"),
  pattern = {
    "checkhealth",
    "dbout",
    "fugitive",
    "gitsigns-blame",
    -- "git",
    -- "gitcommit",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "query",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(event.buf) then
        vim.keymap.set("n", "q", function()
          vim.cmd("close")
          pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
        end, { buffer = event.buf, silent = true, desc = "Quit buffer" })
      end
    end)
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

-- vim.api.nvim_create_autocmd("FileType", {
--   desc = "Disable formatexpr for gitcommit in fugitive",
--   group = augroup("gitcommit_format"),
--   pattern = { "gitcommit" },
--   callback = function()
--     vim.opt_local.formatexpr = ""
--   end,
-- })

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
  desc = "LSP setup",
  group = augroup("lspattach"),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    local function map(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "vim.lsp.buf.definition()")
    map("gD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration()")
    map("grt", vim.lsp.buf.type_definition, "vim.lsp.buf.type_definition()")

    -- diagnostics
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      signs = {
        text = vim.g.has_nerd_font
            and {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.INFO] = " ",
              [vim.diagnostic.severity.HINT] = "󰌶 ",
              -- [vim.diagnostic.severity.ERROR] = " ",
              -- [vim.diagnostic.severity.WARN] = " ",
              -- [vim.diagnostic.severity.HINT] = " ",
              -- [vim.diagnostic.severity.INFO] = " ",
            }
          or {},
      },
      virtual_text = {
        spacing = 4,
        source = "if_many",
      },
      severity_sort = true,
    })

    -- enable LSP completion
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })

      -- LSP completion doc popup
      local _, cancel_prev = nil, function() end
      vim.api.nvim_create_autocmd("CompleteChanged", {
        buffer = event.buf,
        callback = function()
          cancel_prev()
          local info = vim.fn.complete_info({ "selected" })
          local completion_item = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
          if completion_item == nil then
            return
          end
          _, cancel_prev = vim.lsp.buf_request(
            event.buf,
            vim.lsp.protocol.Methods.completionItem_resolve,
            completion_item,
            function(_, item, _)
              if not item then
                return
              end
              local docs = (item.documentation or {}).value
              local win = vim.api.nvim__complete_set(info["selected"], { info = docs })
              if win.winid and vim.api.nvim_win_is_valid(win.winid) then
                vim.treesitter.start(win.bufnr, "markdown")
                vim.wo[win.winid].conceallevel = 3
              end
            end
          )
        end,
      })
    end

    -- LSP codelens mappings
    if client:supports_method("textDocument/codeLens") then
      map("grc", vim.lsp.codelens.run, "vim.lsp.codelens.run", { "n", "v" })
      map("grC", vim.lsp.codelens.refresh, "vim.lsp.codelens.refresh")
    end
  end,
})
