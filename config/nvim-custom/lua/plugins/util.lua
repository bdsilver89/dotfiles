local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "nvim-lua/plenary.nvim",

  {
    "folke/snacks.nvim",
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      },
      dashboard = {
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          {
            pane = 2,
            icon = require("config.icons").git.branch,
            desc = "Browse Repo",
            padding = 1,
            key = "b",
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            action = function()
              Snacks.gitbrowse()
            end,
          },
          function()
            local root = Snacks.git.get_root()
            local in_git = root ~= nil
            if not in_git then
              return {}
            end

            -- get the remote url
            local repo = nil
            for _, line in ipairs(vim.split(vim.trim(vim.fn.system({ "git", "-C", root, "remote", "-v" })), "\n")) do
              local name, remote = line:match("(%S+)%s+(%S+)%s+%(fetch%)")
              if name and remote then
                repo = Snacks.gitbrowse.get_repo(remote)
              end
            end
            if not repo then
              return {}
            end

            local in_github_repo = repo:find("github")
            local in_gitlab_repo = repo:find("gitlab")

            local has_gh = vim.fn.executable("gh") == 1
            local has_glab = vim.fn.executable("glab") == 1

            local cmds = {
              -- {
              --   title = "Notifications",
              --   cmd = "gh notify -s -a -n5",
              --   action = function()
              --     vim.ui.open("https://github.com/notifications")
              --   end,
              --   key = "n",
              --   height = 5,
              --   enabled = has_gh,
              -- },
              {
                title = "Open Issues",
                icon = " ",
                cmd = "gh issue list -L 3",
                key = "i",
                enabled = has_gh and in_github_repo,
                -- height = 7,
              },
              {
                title = "Open PRs",
                icon = " ",
                key = "p",
                cmd = "gh pr list -L 3",
                enabled = has_gh and in_github_repo,
                height = 7,
              },
              {
                title = "Open MRs",
                icon = " ",
                key = "m",
                cmd = "glab mr list -L 3",
                enabled = has_glab and in_gitlab_repo,
                height = 7,
              },
              {
                icon = require("config.icons").git.branch,
                title = "Git Status",
                cmd = "git --no-pager diff --stat -B -M -C",
                height = 10,
                enabled = in_git,
              },
            }

            return vim.tbl_map(function(cmd)
              return vim.tbl_extend("force", {
                pane = 2,
                section = "terminal",
                padding = 1,
                ttl = 5 * 60,
                indent = 3,
              }, cmd)
            end, cmds)
          end,
          { section = "startup" },
        },
      },
    },
  },
}
