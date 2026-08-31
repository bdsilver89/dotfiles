local QUERY = [[
query($url: URI!) {
  resource(url: $url) {
    ... on PullRequest {
      reviewThreads(first: 50) {
        nodes {
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first: 50) {
            nodes {
              author { login }
              body
              url
            }
          }
        }
      }
    }
  }
}
]]

local function load_review_comments()
  vim.system({ "gh", "pr", "view", "--json", "url", "-q", ".url" }, { text = true }, function(pr_res)
    if pr_res.code ~= 0 then
      vim.schedule(function()
        vim.notify("pr-review: not on a PR branch", vim.log.levels.WARN)
      end)
      return
    end

    local pr_url = vim.trim(pr_res.stdout or "")
    if pr_url == "" then
      vim.schedule(function()
        vim.notify("pr-review: no PR URL found", vim.log.levels.WARN)
      end)
      return
    end

    vim.system({
      "gh", "api", "graphql",
      "-f", "query=" .. QUERY,
      "-f", "url=" .. pr_url,
    }, { text = true }, function(api_res)
      if api_res.code ~= 0 then
        vim.schedule(function()
          vim.notify("pr-review: gh api failed: " .. (api_res.stderr or ""), vim.log.levels.ERROR)
        end)
        return
      end

      local ok, decoded = pcall(vim.fn.json_decode, api_res.stdout)
      if not ok or not decoded.data or not decoded.data.resource then
        vim.schedule(function()
          vim.notify("pr-review: bad json response", vim.log.levels.ERROR)
        end)
        return
      end

      local threads = decoded.data.resource.reviewThreads.nodes
      local qf = {}
      for _, t in ipairs(threads) do
        if not t.isResolved then
          for _, c in ipairs(t.comments.nodes) do
            table.insert(qf, {
              filename = t.path,
              lnum = t.line or t.originalLine or 1,
              text = string.format(
                "[%s]%s %s",
                c.author.login,
                t.isOutdated and " (outdated)" or "",
                (c.body or ""):gsub("\n", " ")
              ),
            })
          end
        end
      end

      vim.schedule(function()
        if #qf == 0 then
          vim.notify("pr-review: no unresolved comments", vim.log.levels.INFO)
          return
        end
        vim.fn.setqflist({}, " ", { title = "PR review comments", items = qf })
        vim.cmd("copen")
      end)
    end)
  end)
end

vim.api.nvim_create_user_command("PrReview", load_review_comments, {})
vim.keymap.set("n", "<leader>gR", load_review_comments, { desc = "PR review comments (quickfix)" })
