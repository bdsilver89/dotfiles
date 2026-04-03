local snip_dir = vim.fn.stdpath("config") .. "/snippets"
local cache = {}

local function get_snippets(ft)
  if not cache[ft] then
    local f = io.open(snip_dir .. "/" .. ft .. ".json", "r")
    if not f then cache[ft] = {} return cache[ft] end
    local snips = {}
    for _, s in pairs(vim.json.decode(f:read("*a"))) do
      local body = type(s.body) == "table" and table.concat(s.body, "\n") or s.body
      snips[type(s.prefix) == "table" and s.prefix[1] or s.prefix] = body
    end
    f:close()
    cache[ft] = snips
  end
  return cache[ft]
end

vim.keymap.set({ "i", "s" }, "<c-s>", function()
  local col = vim.fn.col(".") - 1
  local word = vim.fn.getline("."):sub(1, col):match("[%w_-]+$")
  local body = word and get_snippets(vim.bo.filetype)[word]
  if not body then return end
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(line:sub(1, col - #word) .. line:sub(col + 1))
  vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), col - #word })
  vim.snippet.expand(body)
end, { desc = "Expand snippet" })
