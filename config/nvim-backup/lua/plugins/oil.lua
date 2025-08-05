return {
  "stevearc/oil.nvim",
  lazy = vim.fn.argc(-1) == 0,
  cmd = "Oil",
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Oil" },
  },
  opts = {
    default_file_explorer = true,
  },
  config = function(_, opts)
    require("oil").setup(opts)

    -- ########################################################################
    -- oil git integration
    -- ########################################################################
    local group = vim.api.nvim_create_augroup("bdsilver89/oilgit", { clear = true })
    local pattern = "oil://*"
    local ns_id = vim.api.nvim_create_namespace("oil_git_status")

    local default_hls = {
      OilGitAdded = { link = "Added" },
      OilGitModified = { link = "Changed" },
      OilGitRenamed = { link = "Changed" },
      OilGitUntracked = { link = "Comment" },
      OilGitIgnored = { link = "DiffText" },
    }

    -- setup highlights
    for name, hlopts in pairs(default_hls) do
      if vim.fn.hlexists(name) == 0 then
        vim.api.nvim_set_hl(0, name, hlopts)
      end
    end

    local get_git_root = function(path)
      local dir = vim.fn.finddir(".git", path .. ";")
      if dir == "" then
        return nil
      end
      return vim.fn.fnamemodify(dir, ":p:h:h")
    end

    local get_git_status = function(dir)
      local root = get_git_root(dir)
      if not root then
        return {}
      end

      local output = vim.system({ "git", "status", "--porcelain", "--ignored" }, { cwd = root }):wait()
      if output.code ~= 0 then
        return {}
      end

      local status = {}
      for line in output.stdout:gmatch("[^\r\n]+") do
        if #line >= 3 then
          local status_code = line:sub(1, 2)
          local filepath = line:sub(4)

          if status_code:sub(1, 1) == "R" then
            local arrow_pos = filepath:find(" %-> ")
            if arrow_pos then
              filepath = filepath:sub(arrow_pos + 4)
            end
          end

          if filepath:sub(1, 2) == "./" then
            filepath = filepath:sub(3)
          end

          local abs_path = root .. "/" .. filepath
          status[abs_path] = status_code
        end
      end

      return status
    end

    local get_hl_group = function(status_code)
      if not status_code then
        return nil, nil
      end

      local first_char = status_code:sub(1, 1)
      local second_char = status_code:sub(2, 2)

      if first_char == "A" then
        return "OilGitAdded", "+"
      elseif first_char == "M" then
        return "OilGitModified", "~"
      elseif first_char == "R" then
        return "OilGitRenamed", "→"
      end

      if second_char == "M" then
        return "OilGitModified", "~"
      end

      if status_code == "??" then
        return "OilGitUntracked", "?"
      end

      if status_code == "!!" then
        return "OilGitIgnored", "!"
      end

      return nil, nil
    end

    local clear_highlights = function()
      for name, _ in pairs(default_hls) do
        vim.fn.clearmatches()
      end

      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    end

    local apply_highlights = function()
      local oil = require("oil")

      local current_dir = oil.get_current_dir()
      if not current_dir then
        clear_highlights()
        return
      end

      local git_status = get_git_status(current_dir)
      if vim.tbl_isempty(git_status) then
        clear_highlights()
        return
      end

      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      clear_highlights()

      for i, line in ipairs(lines) do
        local entry = oil.get_entry_on_line(bufnr, i)
        if entry and entry.type == "file" then
          local filepath = current_dir .. entry.name

          local status_code = git_status[filepath]
          local hl_group, symbol = get_hl_group(status_code)

          if hl_group and symbol then
            local name_start = line:find(entry.name, 1, true)
            if name_start then
              vim.fn.matchaddpos(hl_group, { { i, name_start, #entry.name } })

              vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 0, {
                virt_text = { { " " .. symbol, hl_group } },
                virt_text_pos = "eol",
              })
            end
          end
        end
      end
    end

    vim.api.nvim_create_autocmd("BufEnter", {
      group = group,
      pattern = pattern,
      callback = function()
        vim.schedule(apply_highlights)
      end,
    })

    vim.api.nvim_create_autocmd("BufLeave", {
      group = group,
      pattern = pattern,
      callback = clear_highlights,
    })

    vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "TextChangedI" }, {
      group = group,
      pattern = pattern,
      callback = function()
        vim.schedule(apply_highlights)
      end,
    })

    vim.api.nvim_create_autocmd({ "FocusGained", "WinEnter", "BufWinEnter" }, {
      group = group,
      pattern = pattern,
      callback = function()
        vim.schedule(apply_highlights)
      end,
    })

    vim.api.nvim_create_autocmd("TermClose", {
      group = group,
      callback = function()
        vim.schedule(function()
          if vim.bo.filetype == "oil" then
            apply_highlights()
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = { "FugitiveChanged", "GitSignsUpdate", "LazyGitClosed" },
      callback = function()
        if vim.bo.filetype == "oil" then
          vim.schedule(apply_highlights)
        end
      end,
    })
  end,
}
