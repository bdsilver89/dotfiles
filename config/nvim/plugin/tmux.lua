local tmux_directions = {
  p = "l",
  h = "L",
  j = "D",
  k = "U",
  l = "R",
  n = "t:.+",
}

local function tmux_command(command)
  local tmux_socket = vim.fn.split(vim.env.TMUX, ",")[1]
  return vim.fn.system("tmux -S" .. tmux_socket .. " " .. command)
end

local function is_tmux_pane_zoomed()
  return tmux_command("display-message -p '#{window_zoomed_flag}'") == "1\n"
end

local function should_tmux_control(is_same_winnr, disable_nav_when_zoomed)
  if is_tmux_pane_zoomed() and disable_nav_when_zoomed then
    return false
  end
  return is_same_winnr
end

local function tmux_change_pane(direction)
  tmux_command("select-pane -" .. tmux_directions[direction])
end

local function vim_navigate(direction)
  if direction == "n" then
    vim.cmd("wincmd w")
  else
    vim.cmd("wincmd " .. direction)
  end
end

local function tmux_navigate(direction)
  if direction == "n" then
  elseif direction == "p" then
  else
    local winnr = vim.fn.winnr()

    vim_navigate(direction)

    local is_same_winnr = (winnr == vim.fn.winnr())
    if should_tmux_control(is_same_winnr, false) then
      tmux_change_pane(direction)
    end
  end
end

local navigate = vim.env.TMUX ~= nil and tmux_navigate or vim_navigate

vim.keymap.set("n", "<c-h>", function() navigate("h") end)
vim.keymap.set("n", "<c-j>", function() navigate("j") end)
vim.keymap.set("n", "<c-k>", function() navigate("k") end)
vim.keymap.set("n", "<c-l>", function() navigate("l") end)
