return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerOpen",
    "OverseerClose",
    "OverseerToggle",
    "OverseerSaveBundle",
    "OverseerLoadBundle",
    "OverseerDeleteBundle",
    "OverseerRunCmd",
    "OverseerRun",
    "OverseerInfo",
    "OverseerBuild",
    "OverseerQuickAction",
    "OverseerTaskAction ",
    "OverseerClearCache",
    -- custom commands
    "Make",
    "Grep",
  },
  -- stylua: ignore
  keys = {
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Overseer Toggle" },
    { "<leader>oc", "<cmd>OverseerRunCmd<cr>", desc = "Overseer Run Command" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer Run Task" },
    { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Overseer Quick Action" },
    { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Overseer Action" },
    { "<leader>ok", "<cmd>OverseerInfo<cr>", desc = "Overseer Info" },
  },
  opts = {
    component_aliases = {
      default = {
        { "display_duration" },
        { "on_output_summarize" },
        "on_exit_set_status",
        "on_complete_notify",
        "on_complete_dispose",
        { "on_output_quickfix" },
      },
    },
  },
  config = function(_, opts)
    local overseer = require("overseer")
    overseer.setup(opts)

    vim.api.nvim_create_user_command("Make", function(params)
      -- Insert args at the '$*' in the makeprg
      local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)
      if num_subs == 0 then
        cmd = cmd .. " " .. params.args
      end
      local task = overseer.new_task({
        cmd = vim.fn.expandcmd(cmd),
        components = {
          { "on_output_quickfix", open = not params.bang, open_height = 8 },
          "default",
        },
      })
      task:start()
    end, {
      desc = "Run your makeprg as an Overseer task",
      nargs = "*",
      bang = true,
    })

    vim.api.nvim_create_user_command("Grep", function(params)
      -- Insert args at the '$*' in the grepprg
      local cmd, num_subs = vim.o.grepprg:gsub("%$%*", params.args)
      if num_subs == 0 then
        cmd = cmd .. " " .. params.args
      end
      local task = overseer.new_task({
        cmd = vim.fn.expandcmd(cmd),
        components = {
          {
            "on_output_quickfix",
            errorformat = vim.o.grepformat,
            open = not params.bang,
            open_height = 8,
            items_only = true,
          },
          -- We don't care to keep this around as long as most tasks
          { "on_complete_dispose", timeout = 30 },
          "default",
        },
      })
      task:start()
    end, { nargs = "*", bang = true, complete = "file" })
  end,
}
